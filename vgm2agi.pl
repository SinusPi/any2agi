#!/usr/bin/perl

if ($ARGV[0] eq "" || $ARGV[0] eq "-h" || $ARGV[0] eq "--help") {
  print <<"USAGE";
VGM2AGI version 0.6.0
(c) 1999-2000 Nat Budin - portions by Lance Ewing
Fixes 2025 by Adam 'Sinus' Skawinski

Usage: it2agi [options] inputfile [outputfile]

Input formats supported: IT, MOD, S3M, XM, MIDI.

Options:
  --readme - show detailed instructions.
  --channels x,x,x,y - select input channels. Default is
    --channels 1,2,3,4 to output first four channels, with
    the last being used as noise. --channels 1,2,3 would
    simply omit the noise channel. Midi channels are
    numbered from 0.
  --tempo-exact - allow exact tempo, at the cost of even
    playback. AGI engine plays using 1/60s ticks, so any
    playback must either use note lengths being multiples
    of 1/60s (at the cost of a different BPM from the
    original - by default), or try to match the original's
    BPM exactly by using varied note lengths.
    MIDI conversion uses exact tempo matching only.
    IT/MOD conversion defaults to "even" playback, snapping
    to 1/60s on every tempo change.
    IT smooth tempo changes are not supported.
  --auto-drum-offs n - automatically terminate notes on
    the noise channel after n ticks. Useful when
    converting input files that use short samples and
    don't bother terminating them, which would turn into
    long noise notes in AGI.
  --instr x note y - force instrument x to play only note
    y. Useful to force a drum-like instrument to play
    only valid AGI drum notes. Typical notes are 13 (high
    noise), 14 (middle noise) and 15 (low noise).
    Combined with --channels to properly map an input
    channel to the noise output, and --auto-drum-offs to
    make output drums shorter, this option can turn a
    typical "rhythm channel" in the input into proper
    noise channel output for AGI.
  --instr x shift y - shift (transpose) instrument x by y
    semitones. Use when input samples were recorded in a
    weird pitch, and notes in the input were written to
    match that. Or, use +12 or -12 to transpose by an
    octave.
  --instr x arp 047 - make instrument x magically generate
    arpeggio 0-4-7 (on ticks defined by --arpspeed)
  --instr x noise 1 - make instrument x on channel 3
    magically insert "pitch borrowing" noise notes
    into the 4th (noise) channel
  --instr x buzz 1 - make instrument x on channel 3
    magically insert "pitch borrowing" buzz notes
    into the 4th (noise) channel
  --arpspeed - set magic arpeggio speed (default: 1)

  --debug-input, --debug-proc, --debug-agi - verbose printout for debugging purposes.
  
Output file is created in the same directory as the input file, with the .AGS extension.
You can also specify a different output file name.

USAGE
;
  exit(1);
}


# $infile = "Aladdin - 17 - Whole New World u.vgm"; #"Aladdin - 02 - One Jump Ahead u.vgm";
$infile = "Aladdin - 02 - One Jump Ahead u.vgm";
open(INFILE, "<".$infile);
binmode(INFILE);

# $outfile = "wnworld.ags";#"aladdin.ags";
$outfile = "aladdin.ags";
open(OUTFILE, ">".$outfile);
binmode(OUTFILE);

read(INFILE,$_,4); # "Vgm "
read(INFILE,$_,4); # eof offset
read(INFILE,$_,4); $ver=unpack("L"); printf("Ver %08x\n",$ver);

read(INFILE,$_,4*6); my ($snclk,$ymclk,$gd3of,$ttsmp,$lpoff,$lpsmp)=unpack("L6"); print($snclk."\n");
read(INFILE,$_,4); $rate=unpack("L");
read(INFILE,$_,2+1); my ($snfed,$snsrw) = unpack("SC"); printf("%04x %04x\n",$snfed,$snsrw);
read(INFILE,$_,1); my @snflg = unpack("B8");
read(INFILE,$_,4+4); my ($ym26c,$ym21c)=unpack("L2");
read(INFILE,$_,4); my $vgmof=unpack("L");
#read(INFILE,$_,16*4+4); my @flags151=unpack("L16C4");

my @snbuf = ();

$latch=0;
$chan[0]{freq}=1; $chan[0]{attn}=15;
$chan[1]{freq}=1; $chan[1]{attn}=15;
$chan[2]{freq}=1; $chan[2]{attn}=15;
$chan[3]{freq}=1; $chan[3]{attn}=15;

seek(INFILE,0x40,0);

for ($chn=0;$chn<=3;$chn++) { $snbuf[$chn]=pack("SCCC",0,0,0x80+($chn<<5),0x80+($chn<<5)+0x1F); }

$DEBUG_OUT=1;
$DEBUG_IN=1;
$DEBUG_DETAIL=1;

#keep reading infile
while (!eof(INFILE)) {
	read(INFILE, $_, 1); $_=unpack("C");
	if ($_==0x50) {
		read(INFILE, $_, 1);
		my $b=unpack("C"); 
		my ($cmd,$chn,$dat) = ($b>>7,($b>>5)&0x3,$b&0x1f);
		if ($cmd) {
			$latch=$chn;
			($vol,$bit4) = (($dat>>4)&0x01,$dat&0x0F);
			if ($vol) { $chan[$latch]{attn}=$bit4; } else { $chan[$latch]{freq}=$bit4; }
		} else {
			$chan[$latch]{freq} |= (($b & 0x3F) << 4);
		}
		printf("%08b",$b) if $DEBUG_IN && !$DEBUG_DETAIL && $latch==1;
		if ($DEBUG_IN && $DEBUG_DETAIL && $latch==1) {
			printf("%-4s %d ",("x"x($latch+1)),$cmd);
			if ($cmd) {
				printf("%02b %d %04b",$chn,$vol,$bit4);
			} else {
				printf("%07b",$dat & 0x3F);
			}
			print "\n";
		}
		#if ($latch!=0) { print(" (ign)\n"); next; };
		#if ($cmd&&!$vol) { print(" (wait)\n"); next; }

		if (substr($snbuf[$latch],-5,2) eq "\x0\x0") { $snbuf[$latch]=substr($snbuf[$latch],0,-5); print "^rm\n" if $DEBUG_OUT && $latch==1; }  # cut off last note if zero duration, it'll be overwritten anyway

		$bytes = pack("SCCC",
			0,
			0x00+0x00+(($chan[$latch]{freq}>>4)&0x3F),
			0x80+($latch<<5)+0x00+($chan[$latch]{freq}&0x0F),
			0x80+($latch<<5)+0x10+($chan[$latch]{attn}&0x0F));
		$snbuf[$latch] .= $bytes;
		$onebuf .= $bytes;
		printf("= %08b %08b %08b\n",
			ord(substr($bytes,2)),
			ord(substr($bytes,3)),
			ord(substr($bytes,4))) if $DEBUG_OUT && $latch==1;
	} elsif ($_==0x61) {
		# wait nn samples
		read(INFILE,$_,2); $del=unpack("S"); $del /= 735; $del=int($del+0.5);
		print ".*$del\n" if $DEBUG_IN;
		for ($chn=0;$chn<=3;$chn++) {
			$snbuf[$chn] = substr($snbuf[$chn],0,-5) . ($d=pack("S",unpack("S",substr($snbuf[$chn],-5,2))+$del)) . substr($snbuf[$chn],-3) if length($snbuf[$chn])>0;
			#print("$chn:d+$del=$d\n");
		}
		$onebuf = substr($onebuf,0,-5) . pack("S",unpack("S",substr($onebuf,-5,2))+$del) . substr($onebuf,-3) if length($onebuf)>0;
	} elsif ($_==0x62) {
		# wait 1/60
		my $del=1;
		for ($chn=0;$chn<=3;$chn++) {
			$snbuf[$chn] = substr($snbuf[$chn],0,-5) . ($d=pack("S",unpack("S",substr($snbuf[$chn],-5,2))+$del)) . substr($snbuf[$chn],-3) if length($snbuf[$chn])>0;
			#print("$chn:d1=$d\n");
		}
		$onebuf = substr($onebuf,0,-5) . pack("S",unpack("S",substr($onebuf,-5,2))+$del) . substr($onebuf,-3) if length($onebuf)>0;
		print".\n" if $DEBUG_IN;
	} elsif ($_==0x63) {
		# wait 1/50
		my $del=1;
		for ($chn=0;$chn<=3;$chn++) {
			$snbuf[$chn] = substr($snbuf[$chn],0,-5) . pack("S",unpack("S",substr($snbuf[$chn],-5,2))+$del) . substr($snbuf[$chn],-3) if length($snbuf[$chn])>0;
		}
		$onebuf = substr($onebuf,0,-5) . pack("S",unpack("S",substr($onebuf,-5,2))+$del) . substr($onebuf,-3) if length($onebuf)>0;
		# print";\n";
	} elsif ($_==0x66) {
		# END
		print"-\n";
		last;
	} elsif ($_==0x4f) {
		# stereo
		read(INFILE, $_, 1);
	} else {
		printf ("UNEXPECTED COMMAND %02x at %x\n",$_,tell(INFILE)-1);
	}

	# COMBINE last 2x5 bytes if their ... nah

	last if (length($snbuf)>10000);
}
close(INFILE);


# for ($i=0;$i<length($snbuf);$i+=5) {
# 	@note1 = unpack("C5",substr($snbuf,$i,5));
#  	@note2 = unpack("C5",substr($snbuf,$i+5,5));
# 	if ($note1[0]+$note1[1]==0 && ($note1&0x80) && (!$b&0x80) && )
# }

$use_onebuf = 0;

if ($use_onebuf) {
	print OUTFILE pack("SSSS",8,length($onebuf)+8,length($onebuf)+8+2,length($onebuf)+8+4);
	print OUTFILE $onebuf . "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF";
} else {
	print OUTFILE "\x08\00";
	$off=8;
	for ($chn=0;$chn<=2;$chn++) {
		$off+=length($snbuf[$chn])+2;
		print OUTFILE pack("S",$off);
	}
	for ($chn=0;$chn<=3;$chn++) {
		print OUTFILE $snbuf[$chn]."\xff\xff";
	}
	print OUTFILE "\xFF\xFF";
}
close(OUTFILE);
