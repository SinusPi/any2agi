#!/usr/bin/perl

# Unix users: if your Perl directory is different than the one
# mentioned above, change the line above to reflect your system
# setup.
#
# Before running IT2AGI, make sure you have Perl 5 or above
# installed on your computer.  Unix users probably already have
# it.  Windows users can get a free Win32 implementation at:
#
# http://www.activestate.com



if ($ARGV[0] eq "--readme") {
print <<"END"
##############################################################
#         Impulse Tracker -> AGI Sound Converter             #
#    (c) 1999-2000 Nat Budin - portions by Lance Ewing       #
#        v0.2.7 enhanced by Adam 'Sinus' Skawinski           #
##############################################################

 To use this program, just type "perl it2agi xxxxxxx.it" where
 xxxxxxx.it is the name of the Impulse Tracker 2.14 file you
 want to convert.  IT2AGI will automatically spit out a file
 called xxxxxxx.ags (where xxxxxxx is the same name as your IT
 file), which is in AGI Sound format.  You can import it into
 your AGI game using AGI Studio 1.3 or higher.

 If you want to specify a different output file name, just
 type "perl it2agi xxxxxxx.it yyyyyyy.ags". It makes most sense
 to use output file names like "SOUND.015", as AGI Studio will
 automatically recognize file type and number when importing
 these files into the game.

 To make an Impulse Tracker file, you'll need
 OpenModPlugTracker, found at https://openmpt.org .

 Input formats:
 * Impulse Tracker (.it) - tempo and volume supported
 * Protracker (.mod) - basic support only, no tempo support
 * MIDI (.mid) - input needs to have monophonic tracks
   or channels, no tempo support yet

Options:

--channels x,x,x,y - select input channels. Default is --channels
  1,2,3,4 to output first four channels, with the last being used
  as noise. --channels 1,2,3 would simply omit the noise channel.
  You'll probably have to use this to pick channels out of
  multi-channel input files, or rearrange them to put the noise
  channel last. Midi channels are numbered from 0.

--tempo-exact - force exact tempo, at the cost of jittery playback.
  AGI engine plays using 1/60s ticks, so any playback must either
  use equal note lengths (at the cost of a different BPM from the
  original - by default), or try to match the original's BPM
  exactly by using varied note lengths. MIDI conversion uses
  exact tempo matching only.

--auto-drum-offs n - automatically terminate notes on the noise
  channel after n ticks. Useful when converting input files that
  use short samples and don't bother terminating them, which
  would turn into long noise notes in AGI.

--instr-note x y - force instrument x to play only note y. Useful
  to force a drum-like instrument to play only valid AGI drum
  notes. Typical notes are 13 (high noise), 14 (middle noise) and
  15 (low noise). Combined with --channels to properly map an
  input channel to the noise output, and --auto-drum-offs to make
  output drums shorter, this option can turn a typical "rhythm
  channel" in the input into proper noise channel output for AGI.

--instr-shift x y - shift (transpose) instrument x by y
  semitones. Use when input samples were recorded in a weird
  pitch, and notes in the input were written to match that. Or,
  use +12 or -12 to transpose by an octave.

##############################################################
    Notes on making IT2AGI-compliant Impulse Tracker files   #
##############################################################

 Things to remember:

 1) The PCjr sound chip supports only 3 voices and 1 noise channel,
    so you'll have to use the first 4 channels of an IT file,
    or use --channels to cherry-pick.

 2) Noise notes are:
    C-0 (high buzz), C#0 (mid buzz), D-0 (low buzz), D#0 (borrow buzz)
    C-1 (high noise), C#1 (mid noise), D-1 (low noise), D#1 (borrow noise)
    "Borrowed" notes play frequencies borrowed from the third channel, though
    not very precisely. They're good for special effects like explosions
    or zaps, though, if you play a series of appropriate notes on
    channel 3 (probably with a volume of 0).    

 2) IT2AGI doesn't (yet) support changing tempo or speed in
    the middle of the song.  Don't try this, as it will be
    cruelly ignored.

 3) Finally, AGI is very limited in what it can do.  If AGI
    doesn't support something, IT2AGI most likely doesn't
    either.

 4) On PC Speaker, only the first channel will be used, other channels
    will be ignored. Keep that in mind when making your input files.
    Of course you can also make two separate files, one monophonic for
    PC Speaker, and one multichannel for PCjr, and play them appropriately
    from within your game, by checking AGI var 22 - but watch out for memory
    limits.

 5) If you're writing an IT file from scratch, set tempo to 150
    and speed to 1. This will give you a perfect match for the
    AGI engine's 60 ticks per second, and 16.67 ms per tick. If that's too
    fast for your editing comfort, set speed to 2-10, but don't touch
    the tempo.

 Oh, and one more: have fun.

<Nat wrote:>

 Many thanks go to Lance Ewing.  Not only did he write the
 AGI Sound specification, enabling my to write this program,
 I also stole a formula off his ROL2SND program.  So, thanks
 Lance!

 If you have any problems running this program (and you will,
 I'm sure), please contact me.  You can email me at:

 natbudin@newmail.net

 Also, if any of you Perl programmers out there spot a bug
 that you think you can fix, email me the bugfix.  You will
 get my undying gratitude and proper credit in the next
 version.

<sinus@sinpi.net takes over>

 Bugs were fixed, new features and input formats were added!
 You can now find this program on GitHub at:
 https://github.com/SinusPi/any2agi

Version history:

 0.2.1: Added recognizing MOD, S3M and XM modules, and MIDI
        files. They're not (yet?) supported, but recognized.
 0.2.2: Experimental option --channels added
 0.2.3: Tempo mode added: --tempo-exact
 0.2.4: Auto drum note-offs added: --auto-drum-offs 1/2/3...
 0.2.5: very basic MOD and MIDI support added
 0.2.6: --auto-drum-offs now use AGI ticks for scale, not rows
        --instr-drum implemented
 0.2.7: --instr-drum changed to --instr-note, and
        --instr-oct to --instr-shift; readme written; tests added
 0.3.0: proper MIDI support, with tempo changes cutting overlapped notes
 0.4.0: MIDI support has drummaps now
 0.5.0: --instr-* syntax changed, arpeggio, portamento, vibrato supported
        magic buzz,noise instruments
 
END
;
  exit(0);
}


if ($ARGV[0] eq "" || $ARGV[0] eq "-h" || $ARGV[0] eq "--help") {
  print <<"USAGE";
IT2AGI version 0.5.0
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
  --tempo-exact - force exact tempo, at the cost of even
    playback. AGI engine plays using 1/60s ticks, so any
    playback must either use equal note lengths (at the
    cost of a different BPM from the original - by
    default), or try to match the original's BPM exactly
    by using varied note lengths. MIDI conversion uses
    exact tempo matching only.
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


@CHANNELS=(1,2,3,4); $CHANNELS_DEFAULT=1;
$AGI_TICK = 1000/60; # 16.6667ms
$POLYMODE = 0;
%DRUMNOTES = (
  35 => { note => 16, length => 33  }, # bass drum
  36 => { note => 16, length => 33 },  # bass drum 1
  37 => { note => 14, length => 17 },   # side stick
  38 => { note => 15, length => 33 },  # snare
  39 => { note => 15, length => 50 },  # clap
  40 => { note => 15, length => 33 },  # elec snare
  41 => { note => 14, length => 33 },  # low tom
  42 => { note => 14, length => 17 },  # hihat closed
  999 => { note => 16, length => 33 },  # hihat closed
);
$IT_CMD_A_SPEED = 1;
$IT_CMD_B_JUMP = 2;  #--
$IT_CMD_C_BREAK = 3; #--
$IT_CMD_D_VOLSL = 4;
$IT_CMD_E_PORTD = 5;
$IT_CMD_F_PORTU = 6;
$IT_CMD_G_PORT = 7;
$IT_CMD_H_VIB = 8;
$IT_CMD_I_TREMR = 9; #--
$IT_CMD_J_ARP = 10;
$IT_CMD_K_VOLSLVIB = 11; #--
$IT_CMD_L_VOLSLPORT = 12; #--
$IT_CMD_M_CHANVOL = 13;
$IT_CMD_N_CHANVOLSL = 14; #--
$IT_CMD_O_OFFSET = 15; #--
$IT_CMD_P_PANSL = 16; #n/a
$IT_CMD_Q_RETRIG = 17; #--
$IT_CMD_R_TREMOLO = 18; #--
$IT_CMD_S_SPECIAL = 19; #--
$IT_CMD_T_TEMPO = 20;
$IT_CMD_U_VIBFINE = 21; #--
$IT_CMD_V_GLOBVOL = 22;
# good to know, but unused
$IT_NOTE_OFF = 246;
$IT_NOTE_CUT = 254;

$ARPSPEED = 0.5; # default arpeggio speed
$GLOBALVOL = 128;

while ($v = shift @ARGV) {
     if ($v eq "--debug-input") { $DEBUG_INPUT=1; }
  elsif ($v eq "--debug-proc") { $DEBUG_PROC=1; }
  elsif ($v eq "--debug-agi") { $DEBUG_AGI=1; }
  elsif ($v eq "--channels") { @CHANNELS = split(",",shift @ARGV); $CHANNELS_DEFAULT=0; }
  elsif ($v eq "--tempo-exact") { $tempomode_override="exact"; }
  elsif ($v eq "--auto-drum-offs") { $auto_drum_offs = shift @ARGV; }
  elsif ($v eq "--instr")  {
    my $instr = shift @ARGV;
    my $meta = shift @ARGV;
    my $data = shift @ARGV;
    if ($meta eq "arp") { $data=hex $data; }
    elsif ($meta eq "shift") { $data = 0+$data; }
    $INSTRDATA[$instr]{$meta}=$data;
  }
  elsif ($v eq "--arpspeed") { $ARPSPEED = 1 / int(shift @ARGV); }
  elsif ($v eq "--length")   { $MAXLENGTH = int(shift @ARGV); }
  elsif ($v eq "--midipoly") { $POLYMODE = 1; }
  elsif ($v eq "--nomidiremap") { $NOMIDIREMAP = 1; }
  else {
    if (!$infile) { $infile = $v; } else { $outfile = $v; }
  }
}
if (!$outfile) { $outfile=$infile; $outfile =~ s/\..+$/.AGS/; }

$NUMCH=$#CHANNELS+1;

if ($NUMCH>4) { die("IT2AGI only supports up to 4 channels.\n"); }

print("Input: $infile  Output: $outfile\n");

open(INFILE, "<".$infile);
binmode(INFILE);

# READING

sub print_di { if ($DEBUG_INPUT) { printf @_; }}
sub print_dp { if ($DEBUG_PROC) { printf @_; }}
sub print_da { if ($DEBUG_AGI) { printf @_; }}

if (its_SND()) {
  die("$infile : The input file seems to be in AGI SOUND format already.\n");
} elsif (its_IT()) {
  read_IT();
} elsif (its_MOD()) {
  read_MOD();
} elsif (its_S3M()) {
  read_S3M();
} elsif (its_XM()) {
  read_XM();
} elsif (its_MID()) {
  read_MID();
} else {
  die("$infile : Unrecognized input file format.\n");
}

sub its_SND() {
  seek(INFILE,0,0);
  read(INFILE,$_,2);
  my ($of1,$of2) = unpack("C2");
  return ($of1==8 && $of2==0);
}

sub its_IT() {
  seek(INFILE,0,0);
  read(INFILE,my $buf,4);
  return ($buf eq "IMPM");
}
sub read_IT() {
  $FORMAT="IT";
  seek(INFILE,4,0); # IMPM
  read(INFILE,$songname,26); $songname = trim($songname);
  print "Reading module '$songname' from $infile\n";

  read(INFILE,$_,2); # rows/beat, rows/meas
  read(INFILE,$_,16);
  ($ordnum, $insnum, $smpnum, $patnum, $cwtv, $cmwt, $flags, $special) = unpack("S6b16b16");
  my ($stereo, $mixopt, $useins, $linear, $oldfx, $compatgxx, $midipitch, $reqmid, $extfilter)
        = split("",$flags,9);
  my ($incmsg, $dum1,   $dum2,   $midcfg, $dum3,   $dum4,   $dum5,   $dum6)
        = split("",$special);

  read(INFILE,$_,6);  ($GLOBALVOL, $mixvol, $IT_SPEED, $IT_TEMPO, $sep, $pwd) = unpack("C6");
  printf "Global volume: %d\n",$GLOBALVOL;
  read(INFILE,$_,10); ($msglgth, $msgoffset, $dum1) = unpack("SI2"); # dum1=="OMPT" :D

  read(INFILE,$_,64); @chnlpan=unpack("C64");
  read(INFILE,$_,64); @chnlvol=unpack("C64",$buf); # all 0s?

  # printf "Channel vols: ";
  # for (my $i=0;$i<64;$i++) {
  #   $chan[$i]{chanvol} = $chnlvol[$i];
  #   printf "%d=%d ",$i+1,$chnlvol[$i];
  # }

  # end of header

  read(INFILE,$_,$ordnum); @orders=unpack("C$ordnum");

  read(INFILE,$_,$insnum*4); @insoff=unpack("I$insnum");
  read(INFILE,$_,$smpnum*4); @smpoff=unpack("I$insnum");
  read(INFILE,$_,$patnum*4); @patoff=unpack("I$patnum");

  print "Pass 1: Reading IT Data\n";

  for (my $ins=0;$ins<$insnum;$ins++) {
    seek(INFILE,$insoff[$ins],0);
    read(INFILE,$_,4); # IMPI
    read(INFILE,$_,13); # filename
    read(INFILE,$_,15); # flags, stuff
    read(INFILE,my $name,26); $name = trim($name);
    
    # $INSTRDATA[$ins]{name}=$name;
    parse_instr_name($ins+1,$name);
  }

  $arow=0;
  $arows=0;

  for ($order=0; $order<($ordnum-1); $order++) {
    my $offset = $patoff[$orders[$order]];
    next if (!$offset);
    print("Reading pattern $order / $ordnum offset $offset\n");
    seek(INFILE,$offset,0);
    read(INFILE,$buf,8);
    ($patlen, $rows, $dum1) = unpack("S2I",$buf);
    $arows+=$rows;

    $row=0;

    READER: while ($row<$rows) {
      $pmvar=$mvar;
      read(INFILE,$buf,1);
      $cvar = unpack("C",$buf);
      if ($cvar==0) {       # end of row
        $row++;
        $arow++;
        print_di "0x%X = next row: %d\n", tell(INFILE)-1,$row;
        next READER;
      }
      $channel = ($cvar - 1) & 63;
        print_di("chan $channel\n");
      $pmvar = $chanmask[$channel];
      if ($cvar & 128) {
        read(INFILE,$buf,1);
        $mvar = unpack("C",$buf);
        print_di "0x%X = mvar %d\n", tell(INFILE)-1,$mvar;
      }
      else {
        $mvar = $pmvar;
        print_di("pmvar $mvar\n");
      }
      $chanmask[$channel]=$mvar;

      if ($mvar & 16) {
        $pattern[$arow][$channel]{note} = $lastval[$channel]{note};
        # print_di($arow.": WTF? ch".$channel." n prev\n");
      }
      if ($mvar & 32) {
        $pattern[$arow][$channel]{instr} = $lastval[$channel]{instr};
      }
      if ($mvar & 64) {
        $pattern[$arow][$channel]{volpan} = $lastval[$channel]{volpan};
        #print_di(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." REv ".$lastval[$channel]{volpan}."\n");
      }
      if ($mvar & 128) {
        $pattern[$arow][$channel]{command} = $lastval[$channel]{command};
        $pattern[$arow][$channel]{param} = $lastval[$channel]{param};
      }

      if ($mvar & 1) {
        read(INFILE,$buf,1);
        $lastval[$channel]{note} = $pattern[$arow][$channel]{note} = unpack("C",$buf);
        #print_di(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." n ".unpack("C",$buf)."\n");
      }
      if ($mvar & 2) {
        read(INFILE,$buf,1);
        $lastval[$channel]{instr} = $pattern[$arow][$channel]{instr} = unpack("C",$buf);
        #print_di(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." i ".unpack("C",$buf)."\n");
      }
      if ($mvar & 4) {
        read(INFILE,$buf,1);
        $lastval[$channel]{volpan} = $pattern[$arow][$channel]{volpan} = unpack("C",$buf);
        #print_di(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." v ".unpack("C",$buf)."\n");
      }
      if ($mvar & 8) {
        read(INFILE,$buf,2);
        ($pattern[$arow][$channel]{command},
        $pattern[$arow][$channel]{param}) = unpack("CC",$buf);
        $lastval[$channel]{command}=$pattern[$arow][$channel]{command};
        $lastval[$channel]{param}=$pattern[$arow][$channel]{param};
        #print_di(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." cp ".unpack("CC",$buf)."\n");
      }

      if ($pattern[$arow][$channel]{note}>0 && $INSTRDATA[$pattern[$arow][$channel]{instr}]{shift})  { $lastval[$channel]{note} = $pattern[$arow][$channel]{note} = $pattern[$arow][$channel]{note} + $INSTRDATA[$pattern[$arow][$channel]{instr}]{shift}; }

      print_di "0x%X = %s ch%d: n=%d i=%d v=%d c=%d p=%d\n",
        tell(INFILE)-1,
        $mvar&1 ? "note" : "",
        $channel,
        $pattern[$arow][$channel]{note} || 0,
        $pattern[$arow][$channel]{instr} || 0,
        $pattern[$arow][$channel]{volpan} || 0,
        $pattern[$arow][$channel]{command} || 0,
        $pattern[$arow][$channel]{param} || 0;
    }
  }
  close(INFILE);
}

sub its_MOD() {
  seek(INFILE,0x438,0);
  read(INFILE,my $buf,4);
  return ($buf eq "M.K.");
}
sub read_MOD() {
  $FORMAT="MOD";
  seek(INFILE,0,0);
  read(INFILE,my $title,20);
  print("Pass 1. Reading Protracker module '$title'...\n");
  # samples, ignore
  for (my $sn=0;$sn<31;$sn++) {
    read(INFILE,my $sname,22); $sname = trim($sname);
    read(INFILE,$_,8); my ($slen,$stune,$svol,$reps,$repl) = unpack("SCCSS");
    parse_instr_name($sn+1,$sname);
    # print_di "S%02d: %s\n",$sn,$sname;
  }
  read(INFILE,$_,1); $songlen=unpack("C");
  read(INFILE,$_,1);
  read(INFILE,$_,128); @songpats = unpack("C*",substr($_,0,$songlen));
  read(INFILE,$mk,4); if ($mk!="M.K.") { die("MOD broken! $mk\n"); }

  # my $maxpat=0; for (my $i=0;$i<128;$i++) { my $p=ord(substr($songpats,$i,1)); $maxpat=$p if ($p>$maxpat); }

  print_di "Song length: %d, patterns: %s\n",$songlen,join(",",@songpats);

  $IT_TEMPO=120; $IT_SPEED=6;

  $patdataoffset = 1084;
  $patdatalen = 1024;

  $modpatlen=64;
  $modchannels=4;

  $arow=0;

  $periods = [ 999, 856,808,762,720,678,640,604,570,538,508,480,453, 428,404,381,360,339,320,302,285,269,254,240,226, 214,202,190,180,170,160,151,143,135,127,120,113 ];
  %periodtonote = map { $periods->[$_] => 48 + $_ } 0..$#{$periods};
  
  for (my $pos=0;$pos<$songlen;$pos++) {
    $pat = $songpats[$pos];
    seek(INFILE,$patdataoffset + $patdatalen*$pat,0);
    print_di "reading pat ".$pat."\n";
    for (my $row=0;$row<$modpatlen;$row++) {
      print_di "%02d = ",$row;
      for (my $chan=0;$chan<$modchannels;$chan++) {
        read(INFILE,$_,4); my ($b1,$b2,$b3,$b4) = unpack("CCCC");
        $instr = ($b1&0xF0) | ($b3>>4);
        $period = (($b1&0x0F)<<8) | $b2;
        $command = $b3&0x0F;
        $args = $b4;
        if (!$instr && !$period && !$command) {
          print_di "              ";
          next;
        }
        my $note;
        my $notedata = {};
        if ($period) {
          $note = $periodtonote{$period} || -1;
          if ($note>0 && $INSTRDATA[$instr]{shift})  { $note+=$INSTRDATA[$instr]{shift}; }
          if ($note>0 && $INSTRDATA[$instr]{note}) { $note=$INSTRDATA[$instr]{note}; }
          $notedata->{note} = $note;
          $notedata->{instr} = $instr;
          $notedata->{volpan} = 64; # default volume
        }

        if ($command==0x0C) { $notedata->{volpan}=$args; }
        #if ($INSTRARP[$instr]) { $notedata->{instrarp}=$INSTRARP[$instr]; }
        $pattern[$arow+$row][$chan] = $notedata;
        
        print_di "i%02d n%02d c%1X%02x  ",$instr,$periodtonote{$period},$command,$args
      }
      print_di "\n";
    }
    $arow+=$modpatlen;
  }
  close(INFILE);
}

sub its_S3M() {
  seek(INFILE,0x2C,0);
  read(INFILE,my $buf,4);
  return ($buf eq "SCRM");
}
sub read_S3M() {
  $FORMAT="S3M";
  seek(INFILE,0,0);
  read(INFILE,my $title,0x14);
  print("Reading ScreamTracker3 module '$title'...\n");
  die("$infile : Sorry, S3Ms are not yet supported.\n");
}

###########################################################################

sub its_XM() {
  seek(INFILE,0x26,0);
  read(INFILE,my $buf,11);
  return ($buf eq "FastTracker");
}
sub read_XM() {
  $FORMAT="XM";
  seek(INFILE,0x11,0);
  read(INFILE,my $title,0x14);
  print("Reading FastTracker module '$title'...\n");
  die("$infile : Sorry, XMs are not yet supported.\n");
}

###########################################################################

sub its_MID() {
  seek(INFILE,0,0);
  read(INFILE,my $buf,4);
  return ($buf eq "MThd");
}
sub read_MID() {
  $FORMAT="MIDI";
  seek(INFILE,0,0);
  $chunks=0;

  if ($CHANNELS_DEFAULT) { @CHANNELS=(1,2,3,10); $NUMCH=4;} # default channels

  my $miditempo = 500000; # default tempo
  my $miditicksbeat = 192; # default ticks per beat
  
  my $MIDICH_DRUM = 9; # default drum channel

  my $mididata = [];

  print "Pass 1: Reading MIDI Data\n";

  do {
    read(INFILE,my $chunktype,4);
    read(INFILE,$_,4); $length = unpack("L>");
    read(INFILE,my $chunkbuf,$length);

    my @readchans;
    for (my $ch=0;$ch<$NUMCH;$ch++) { $readchans[$CHANNELS[$ch]]=1; }

    if ($chunktype eq "MThd") {
    
      ## read header
      my ($format,$ntrks,$div) = unpack("S>[3]",$chunkbuf);
      my $divtype = $div & 0x8000;
      if ($divtype==0) { $miditicksbeat = $div & 0x7FFF; }
      else { ($negsmpte,$ticksperf)=(($div & 0x7F00)>>8,($div & 0x00FF)); }
      print_di "Header: format $format, $ntrks tracks, ticks/beat=$miditicksbeat, negsmpte=$negsmpte, ticksperf=$ticksperf\n";

    } elsif ($chunktype eq "MTrk") {
    
      open(my $bufread,'<',\$chunkbuf);
      $tracks++;
      print_di "Reading track $tracks, $length bytes\n";

      my $totalticks=0;
      my $totalsec=0;
      my $totalms=0;
      undef @last;

      $polychans = 0; # currently playing

      do {{
        $delta = read_vlq($bufread);
        $totalticks+=$delta;

        $deltams = $delta / $miditicksbeat * $miditempo / 1000; # timestamp in ms
        $totalms += $deltams;

        print_di "[+%5d=%5d=%7.3fs]: ",$delta,$totalticks,$totalms;

        read($bufread,$_,1); $status=unpack("C",$_);
        if ($status&0x80) {
          print_di "Status %08b  ",$status;
        } else {
          $status=$oldstatus; seek($bufread,-1,1); # keep old status, go back a byte
          print_di "   ... %08b  ",$status;
        }
        $type=($status&0xF0)>>4;
        $chan=($status&0x0F);
        $oldstatus=$status;

        # ugly hack for note-on 0-velocity being used as note-off
        if ($type==0b1001) {
          read($bufread,$_,2); ($k,$v)=unpack("CC");
          if ($v==0) { $type=0b1000; } # note-off
          seek($bufread,-2,1); # go back
        }

        if ($type==0b1001) {
          read($bufread,$_,2); ($k,$v)=unpack("CC"); print_di "$chan N-ON $k=$v ";
          #if ($chan>5) { next; }
          if ($POLYMODE && $chan!=$MIDICH_DRUM) { # polyphonic mode
            if ($polychans<3) { # there's still space?
              $midipoly[$polychans] = { chan=>$chan, poly=>$polychans, note=>$k, vol=>$v>>1, start=>$totalms }; # start note
              $polychans++;
              print_di "<<. *".$polychans;
            }
          } else { # monophonic mode
            print_di "<<. ";
            if ($last[$chan]{note} && $last[$chan]{note}!=$k) { # different note, abort previous note
              print_di "!".$last[$chan]{note};
              $last[$chan]{length} = $totalms-$last[$chan]{start};
              if ($last[$chan]{length}>0) { # only if it's not zero-length, otherwise just drop it
                push @{$mididata[$chan]}, $last[$chan];
              } else {
                print_di "-";
              }
            }
            
            $last[$chan] = { note=>$k, vol=>$v>>1, start=>$totalms }; # start note
          }
        }
        elsif ($type==0b1000) {
          read($bufread,$_,2); ($k,$v)=unpack("CC"); print_di "$chan N-OF $k=$v ";
          #if ($chan>5) { next; }
          if ($POLYMODE && $chan!=$MIDICH_DRUM) { # polyphonic mode
            for (my $poly=0;$poly<$polychans;$poly++) { # find the note already playing
              $pnote = $midipoly[$poly];
              if ($pnote->{chan}==$chan && $pnote->{note}==$k) {
                $pnote->{length} = $totalms-$pnote->{start}; # end note
                if ($poly<3) { push @{$mididata[$pnote->{poly}]}, $pnote; } # low 3 midipolys actually play
                splice(@midipoly,$poly,1);
                #if ($midipoly[2]) { # just pulled from back buffer
                #  $midipoly[$poly]{start} = $totalms; # end note
                #}
                print_di "<<' *".$polychans;
                $polychans--;
                last;
              }
              # start playing the next note if there are still some left
            }
          } else { # monophonic mode
            if ($last[$chan]{note}==$k) {
              if ($chan!=9 || !$last[$chan]{length}) { # keep the note length for drums
                $last[$chan]{length} = $totalms-$last[$chan]{start};
              }
              push @{$mididata[$chan]}, $last[$chan];
              delete $last[$chan];
              print_di "<<'";
            }
          }
        }
        elsif ($type==0b1010) { read($bufread,$_,2); ($k,$v)=unpack("CC"); print_di "$chan AFTT $k=$v "; }
        elsif ($type==0b1011) { read($bufread,$_,2); ($k,$v)=unpack("CC"); print_di "$chan CTRL $k=$v "; }
        elsif ($type==0b1100) { read($bufread,$_,1); $pc=unpack("C"); print_di "$chan PCHG $pc "; }
        elsif ($type==0b1101) { read($bufread,$_,1); $v=ord($_); print_di "$chan AFTC $k=$v "; }
        elsif ($type==0b1110) { read($bufread,$_,2); $v=ord($_); print_di "$chan PWHL $k=$v "; }
        elsif ($status==0b11110000) { print_di "SSX0 "; $len=read_vlq(); read($bufread,$buf,$len); print_di "[%s]",$buf; } # do { read($bufread,$buf,1); } until (ord($buf)==0b11110111); }
        elsif ($status==0b11110111) { print_di "SSX1 "; $len=read_vlq(); read($bufread,$buf,$len); } # do { read($bufread,$buf,1); } until (ord($buf)==0b11110111); }
        elsif ($status==0b11110010) { read($bufread,$buf,2); }
        elsif ($status==0b11110011) { read($bufread,$buf,1); }
        elsif ($status==0b11111111) { # meta 
          read($bufread,$_,1); $meta=unpack("C");
          $len=read_vlq($bufread);
          print_di "META%02x[%d] ",$meta,$len;
          read($bufread,$metadata,$len);
          my $a=ord($metadata[0]);
             if ($meta==0x00) { print_di "SEQN %d",$a; }
          elsif ($meta<=0x07) { print_di "[%s]",$metadata; }
          elsif ($meta==0x20) { print_di "CHAN %d",$a; }
          elsif ($meta==0x21) { }
          elsif ($meta==0x2F) { print_di "EOTR"; }
          elsif ($meta==0x51) { ($t1,$t2,$t3)=unpack("C3",$metadata); $t=($t1<<16)+($t2<<8)+$t3; $miditempo=$t; print_di("TMPO %d = %d bpm",$t,60000000/$t); }
          elsif ($meta==0x54) { (my $s,$m,$p,$t,$e)=unpack("C5",$metadata); print_di("SMPT %d:%d:%d:%d:%d",$s,$m,$p,$t,$e); }
          elsif ($meta==0x58) { (my $n,$d,$clk,$b32)=unpack("C4",$metadata); $d=2**$d; print_di("TSIG %d/%d %dclk %d*32/beat",$n,$d,$clk,$b32); }
          elsif ($meta==0x59) { ($sf,$mi)=unpack("cC"); print_di("KSIG %d %s",$sf,($mi?"min":"maj")); }
          elsif ($meta==0x7f) { print_di "[%s]",$buf; }
        }
        else { print_di "Unknown status %08b\n",$status; }
        print_di "\n";
        # $i++; if ($i==100) { die(); }
      }} until (eof($bufread));
    }
    $chunks++; die ("$infile : ERROR: too many chunks?") if ($chunks>100);
  } until (eof(INFILE));

  close(INFILE);

  # merge channels, prevent overlaps
  for (my $midichan=0; $midichan<16; $midichan++) {
    $mididata[$midichan] = [ sort { $a->{start} <=> $b->{start} } @{$mididata[$midichan]} ];
  }

  # prevent overlaps, may have been added when merging
  for (my $midichan=0; $midichan<16; $midichan++) {
    for (my $nn=1; $nn<scalar(@{$mididata[$outchan]}); $nn++) {
      my $current_note = $mididata[$outchan][$nn];
      my $previous_note = $mididata[$outchan][$nn-1];

      if ($previous_note->{start} + $previous_note->{length} > $current_note->{start}) { $previous_note->{length} = $current_note->{start}-$previous_note->{start}; }
    }
  }

  if ($DEBUG_INPUT) {
    print "\nMIDI INPUT:\n";
    for (my $midichan=0; $midichan<16; $midichan++) {
      $notecount = scalar(@{$mididata[$midichan]});
      next if ($notecount==0); # skip empty channels
      printf "MIDI Channel %d:\n",$midichan+1;
      for (my $nn=0; $nn<scalar(@{$mididata[$midichan]}); $nn++) {
        my $no=$mididata[$midichan][$nn];
        printf "%3d. start %6.2f, len %6.2f, note %d\n",$nn+1,$no->{start},$no->{length},$no->{note};
      }
    }
  }

  # MIDI!
  #for (my $outchan=0; $outchan<$NUMCH; $outchan++) {
  #  $inchan = $CHANNELS[$outchan];
  #  printf "MIDI channel %d maps to output %d, %d notes\n",$inchan,$outchan+1,scalar(@{$mididata[$inchan]});
  #  $tunedata[$outchan] = $mididata[$inchan];
  #}

  $arows = 0;
  for (my $outchan=0; $outchan<$NUMCH; $outchan++) {
    $inchan = $CHANNELS[$outchan]-1;
    $notecount = scalar(@{$mididata[$inchan]});
    next if ($notecount==0); # skip empty channels
    print_di "Patternizing MIDI channel %d: %d notes\n",$inchan,$notecount;
    for (my $nn=0; $nn<$notecount; $nn++) {
      my $no = $mididata[$inchan][$nn];
      my $row_start = int($no->{start} / $AGI_TICK + 0.5);
      $pattern[$row_start][$inchan] = { 
        note => $no->{note},
        volpan => defined($no->{vol}) ? $no->{vol}>>1 : 0, # volume to IT volume
        # rows => int($no->{length} / $AGI_TICK + 0.5), # length in AGI ticks
      };

      my $row_end = int(($no->{start} + $no->{length}) / $AGI_TICK + 0.5);
      $pattern[$row_end][$inchan] = { 
        note => $IT_NOTE_OFF,
        # volpan => $no->{vol} ? $no->{vol}>>1 : 64, # volume to AGI volume
        # rows => int($no->{length} / $AGI_TICK + 0.5), # length in AGI ticks
      };

      print_di "Row %d-%d note %d volpan %d\n",$row_start,$row_end,$pattern[$row_start][$inchan]{note},$pattern[$row_start][$inchan]{volpan};

      $arows = $row_end if ($row_end > $arows);
    }
  };
  $IT_TEMPO = 150; $IT_SPEED = 1; # default tempo and speed
  print_di "Total rows: %d\n",$arows+1;
}

sub read_vlq {
  $FH = shift;
  $out=0;
  do {
    read($FH,my $buf,1); $b = ord($buf);
    #printf("[%02x]",$b);
    $out = ($out<<7) + ($b & 0x7F);
  } while ($b & 0x80);
  #printf("=%3d ",$out);
  return $out;
}

###########################################################################
# After reading a tracker module, we're expecting to have a big $pattern[$row][$channel]{note,instrument,volpan,command,param} with all patterns glued.
# NOT NEEDED when working with a MIDI file.


if (0 && @pattern) {
  $tunedata=[];

  print "Using channels ".join(",",@CHANNELS)."\n";

  print "Pass 2: Finding Note Lengths\n";

  $tempomode = $tempomode_override || "even";
  
  my $rowdur_ms = (2500 / $IT_TEMPO) * $IT_SPEED; # 2500 is the default IT row duration in ms
  printf "Using tempo %d speed %d, 'classic' tempo: 1 row = %.2f ms\n",$IT_TEMPO,$IT_SPEED,$rowdur_ms;
  if ($tempomode eq "even") {
    # pull the row duration to be a multiple of AGI ticks
    $mul = int($rowdur_ms/$AGI_TICK + 0.5); if ($mul<1) { $mul=1; }
    $rowdur_ms = $mul*$AGI_TICK;
    printf "Tempo mode is 'even', row = %d AGI ticks (%.2f ms)\n",$mul,$rowdur_ms;
  } else {
    print "Tempo mode is 'exact', row playback may be uneven.\n";
  }

  $arows = $#pattern+1;


  # row timing recalculation - DISABLED for now!
  if (0) {
    $rowstarts_ms = [0];
    $rowstartms = 0;
    for (my $row=0; $row<=$arows; $row++) {
      $rowstarts_ms->[$row] = $rowstartms;
      for (my $inchan=0; $inchan<16;$inchan++) {
        my $note=$pattern[$row][$inchan];
        if ($FORMAT eq "IT" && $note->{command}==$IT_CMD_A_SPEED) {
          $IT_SPEED = $note->{param};
          $rowdur_ms = (2500 / $IT_TEMPO) * $IT_SPEED; # recalculate row duration
          if ($tempomode eq "even") {
            # pull the row duration to be a multiple of AGI ticks... again
            $mul = int($rowdur_ms/$AGI_TICK + 0.5); if ($mul<1) { $mul=1; }
            $rowdur_ms = $mul*$AGI_TICK;
          }
          printf "Row %d: speed command, new row duration %.2f ms\n",$row,$rowdur_ms;
        } elsif ($FORMAT eq "IT" && $note->{command}==$IT_CMD_T_TEMPO) {
          if ($note->{param}&0x80>>4 == 0) {
            printf("T0x command unsupported, skipping.\n");
          } elsif ($note->{param}&0x80>>4 == 1) {
            printf("T1x command unsupported, skipping.\n");
          } elsif ($note->{param}&0x80>>4 >= 2) {
            $IT_TEMPO = $note->{param};
          }
          $rowdur_ms = (2500 / $IT_TEMPO) * $IT_SPEED; # recalculate row duration
          if ($tempomode eq "even") {
            # pull the row duration to be a multiple of AGI ticks... again
            $mul = int($rowdur_ms/$AGI_TICK + 0.5); if ($mul<1) { $mul=1; }
            $rowdur_ms = $mul*$AGI_TICK;
          }
          printf "Row %d: tempo command, new row duration %.2f ms\n",$row,$rowdur_ms;
        }

      }
      $rowstartms += $rowdur_ms;
    }
  }

}


for (my $ins=1;$ins<scalar(@INSTRDATA);$ins++) {
  # Print details of the current instrument
  next if (!keys %{$INSTRDATA[$ins]});
  printf "Instrument %2d: [%-32s]",$ins,$INSTRDATA[$ins]{name};
  if (defined $INSTRDATA[$ins]{noise}) { print "; Noise"; }
  if (defined $INSTRDATA[$ins]{buzz}) { print "; Buzz"; }
  if (defined $INSTRDATA[$ins]{shift}) { printf "; Shift %+.2f",$INSTRDATA[$ins]{shift}; }
  if (defined $INSTRDATA[$ins]{note}) { printf "; One-note %d",$INSTRDATA[$ins]{note}; }
  if (defined $INSTRDATA[$ins]{arp}) { printf "; Arpeggio %03x",$INSTRDATA[$ins]{arp}; }
  if (defined $INSTRDATA[$ins]{vib}) { printf "; Vibrato %03x",$INSTRDATA[$ins]{vib}; }
  print "\n";
}


my $NOTE_BORROW_BUZZ = 3;
my $NOTE_BORROW_NOISE = 15;

# process magic drums
for (my $row=0; $row<=$arows; $row++) {
  my $note = $pattern[$row][2];
  if ($note->{note} && $note->{note}<120 && $note->{instr} && ($INSTRDATA[$note->{instr}]{noise} || $INSTRDATA[$note->{instr}]{buzz})) {
    my $magic = $INSTRDATA[$note->{instr}]{noise} ? $NOTE_BORROW_NOISE : $NOTE_BORROW_BUZZ;
    $pattern[$row][3]={note=>$magic,volpan=>$note->{volpan},magic=>1};
    $note->{magicsource}=1;
    $note->{volpan}=0;
  } elsif (($note->{note}==$IT_NOTE_CUT || $note->{note}==$IT_NOTE_OFF) && $row>0 && $pattern[$row-1][3]->{magic}) {
    $pattern[$row][3]={note=>$IT_NOTE_CUT,volpan=>0,magic=>1};
  }
}
for (my $row=$arows-1; $row>=1; $row--) {
  my $pnote = $pattern[$row-1][3];
  my $note = $pattern[$row][3];
  if ($note->{magic} && $pnote->{magic} && $note->{note}==$pnote->{note} && $note->{volpan}==$pnote->{volpan}) {
    undef $pattern[$row][3];
  }
}



if ($DEBUG_PROC) {
  print "PROCESSING PATTERN:\n";
  # print numbers of channels in $CHANNELS in one line
  print "      "; print join("  |  ", map { sprintf "  Channel %2d  ", $_ } @CHANNELS); print "\n";

  for ($row=0; $row<scalar(@pattern); $row++) {
    printf "%4d. ",$row+1;
    for (my $outchan=0; $outchan<$NUMCH; $outchan++) {
      my $inchan = $CHANNELS[$outchan]-1;
      my $note=$pattern[$row][$inchan];
      printf "n%3s v%2s %2s %2s  |  ",
        defined $note->{note} ? (($note->{note}==$IT_NOTE_CUT||$note->{note}==$IT_NOTE_OFF) ? "^^^" : sprintf "%3d",$note->{note}) : "---",
        defined $note->{volpan} ? sprintf "%2d",$note->{volpan} : "--",
        defined $note->{command} ? sprintf "%2d",$note->{command} : "--",
        defined $note->{param} ? sprintf "%02x",$note->{param} : "--";
    }
    printf "\n";
  }
}

#############################################################################################################
# Here we're expecting to have $tunedata[channel][]{row,note,rows,vol,start,length} to insert rests between notes.

sub min ($$) { $_[$_[0] > $_[1]] }

print "Pass 3: Rendering rests and effects\n";
$notedata = [];

my $ticks_per_row=1;
if ($IT_TEMPO) {
  my $rowdur_ms = (2500 / $IT_TEMPO) * $IT_SPEED; # 2500 is the default IT row duration in ms
  printf "Tempo %d speed %d, 'classic' tempo: 1 row = %.2f ms\n",$IT_TEMPO,$IT_SPEED,$rowdur_ms;
  $tempomode = $tempomode_override || "even";
  if ($tempomode eq "even") {
    # pull the row duration to be a multiple of AGI ticks
    $ticks_per_row = int($rowdur_ms/$AGI_TICK + 0.5); if ($ticks_per_row<1) { $ticks_per_row=1; }
    $rowdur_ms = $ticks_per_row*$AGI_TICK;
    printf "Tempo mode is 'even', row = %d AGI ticks (%.2f ms)\n",$ticks_per_row,$rowdur_ms;
  } else {
    print "Tempo mode is 'exact', row playback may be uneven.\n";
  }
}

$arows = $#pattern+1;

if ($MAXLENGTH) {
  my $oldarows = $arows;
  $arows = min($arows,$MAXLENGTH); # limit the number of rows
  print "Total rows $oldarows, limited to $arows.\n";
}

my $row_ticks = 0;

for (my $outchan=0; $outchan<$NUMCH; $outchan++) { $notedata[$outchan] = []; $chans[$outchan] = { }; } # no note playing

ROW:
for (my $row=0; $row<=$arows; $row++) {

  $row_ticks += $ticks_per_row; # how many AGI ticks in this row?


  # GLOBAL commands, handle before anything else
  undef $changed_globvol;
  for (my $outchan=0; $outchan<$NUMCH; $outchan++) {
    my $inchan = $CHANNELS[$outchan]-1;
    my $note = $pattern[$row][$inchan];
    if ($note->{command}==$IT_CMD_V_GLOBVOL) {
      $GLOBALVOL = $note->{param}; if ($GLOBALVOL>128) { $GLOBALVOL=128; }
      print_dp "Global volume set to %d\n",$GLOBALVOL;
      delete $note->{command}; delete $note->{param}; # remove command
      $changed_globvol = 1; # mark row volume changed
    }
  }


  CHAN:
  for (my $outchan=0; $outchan<$NUMCH; $outchan++) {
    my $inchan = $CHANNELS[$outchan]-1;
    my $note = $pattern[$row][$inchan];
    if (!$note && $row==0) { # first row, no note
      $note = { note => -1, vol => 0 }; # no note playing
    }

    my %chan = %{$chans[$outchan]};

    # commands don't carry over solid rows, only over extras
    delete $chan{command};
    delete $chan{param};
    undef $changed_note_ovr; if ($chan{fxnote}) { delete $chan{fxnote}; $changed_note_ovr=1; };

    # what's at this row in this channel? an old note still playing, or a new note?
    for (my $m=0;$m<$row_ticks;$m++) { # repeat for each AGI tick in this row
      print_dp "%3s %4d%3s, channel %d from %d: ",($m==0?"Row":""),$row+1,$m>0?sprintf("+%2d",$m):"",$outchan+1,$inchan+1;
      if ($m>0) {
        undef $note; # no note, simulate empty row
      }
      
      my %changed = ();
      if ($changed_globvol && $m==0) { $changed{vol}=1; } # for all channels
      if ($chan{overridden}) { undef $note; delete $chan{overridden}; next ROW; }
      if ($changed_note_ovr) { $changed{note} = $changed_note_ovr; undef $changed_note_ovr; }
      
      if ($note) { # SOMETHING changes, not necessarily a new note
        print_dp "NEW: ".join(" ",map { "$_=$note->{$_}" } sort keys %{$note})."; ";
        # new note, start playing it
        if (defined $note->{note}) {
          my $n = $note->{note};
          if ($n==$IT_NOTE_CUT || $n==$IT_NOTE_OFF) { $note->{note}=-1; } # -1 means rest
          #$chan{newnote}=$n; # base note
        }
        if (defined $note->{volpan} || defined $note->{note}) {
          my $vol = (defined $note->{volpan} && $note->{volpan}<=64) ? $note->{volpan} : 64; # volume, default 64
          #if ($vol&0x60) { $vol=$chan{vol}-$vol&0x1F; }
          #if ($vol&0x60) { $vol=$chan{vol}-$vol&0x1F; }
          if ($note->{note}==-1) { $vol = 0; } # no note, no volume
          #if ($chan{note}!=$vol) {
          $chan{vol} = $vol; # volume
          $changed{vol} = 1;
          #}
        }
        #if ($not>0 && $not<200 && !defined($vol)) { $vol=32; } # temp default volume?        
        
        if ($note->{note}==-1 && scalar(@{$notedata[$outchan]}) && $notedata[$outchan][-1]{note}==-1) {
          # just continue the rest, likely a drum-off
          delete $note->{note};
          $notedata[$outchan][-1]{length}++;
          %{$chans[$outchan]} = %chan;
          next;
        }

        if (defined $note->{instr}) { $chan{instr} = $note->{instr}; $changed{instr}=1; } # instrument number - unused in AGI - _unless_ for magic noise!
        if (defined $note->{command}) {
          $chan{command} = $note->{command};
          $changed{command} = 1; # command : may not change
        }
        if (defined $note->{param}) {
          $chan{param} = $note->{param};
          $changed{param} = 1; # param : may not change
        }
      }

      print_dp "[ %s ]; ",join(" ",map { "$_=$chan{$_}" } sort keys %chan);

      # now do effects, based on $chan

      if ($outchan==3 && $auto_drum_offs && scalar @{$notedata[$outchan]} && $notedata[$outchan][-1]{note}>0 && $notedata[$outchan][-1]{length}>=$auto_drum_offs) {
        # auto drum off
        delete $chan{fxnote};
        $chan{note}=-1; $chan{vol}=0;
        $changed{note}=1; $changed{vol}=1;
        print_dp "= drum off! ";

      } elsif ($chan{command}==$IT_CMD_E_PORTD || $chan{command}==$IT_CMD_F_PORTU || ($chan{command}==$IT_CMD_G_PORT && ($note->{note} // $chan{mem_porta_note}))) { # portamento

        delete $chan{fxnote};
        my $target_note = $note->{note} // $chan{mem_porta_note};
        my $p_up = $chan{command}==$IT_CMD_F_PORTU || ($chan{command}==$IT_CMD_G_PORT && $target_note>$chan{note});
        my $p_to = $chan{command}==$IT_CMD_G_PORT;
        my $p_step = $chan{param} || $chan{mem_porta_cmd};
        $chan{mem_porta_cmd}=$p_step;
        $chan{mem_porta_note}=$note->{note} if defined $note->{note};
        $p_step=-$p_step if (!$p_up);
        my $portanote = $chan{note} + $p_step / 16; # output note is the same as input note
        if ($p_to && (($p_up && $portanote>$target_note) || (!$p_up && $portanote<$target_note))) { $portanote=$target_note; }
        print_dp "= portamento %s%s from %.1f %+d/16 = %.1f; ", ($p_up?"up":"dn"),($p_to?" to $target_note":""),$chan{note},$p_step, $portanote;
        if ($chan{note}!=$portanote) {
          $chan{note}=$portanote; # note to output, actual change
          $changed{note} = 1; # note changed
        }
      
      } elsif ($chan{command}==$IT_CMD_H_VIB || $INSTRDATA[$chan{instr}]{vib}) { # VIBRATO

        $chan{note} = $note->{note} if defined $note->{note}; # change if changed

        my $VIBLENGTH = 64; my $VIBDEPTH = 1;

        my $vibphase = int($chan{vibphase}+0.01)||0; # fix rounding errors, let 0.99 be 1
        if (defined $note->{note}) { $vibphase = 0; } # reset vibrato phase on note change
        my $vibs = $chan{command}==$IT_CMD_H_VIB ? ($chan{param} || $chan{mem_vibra}) : $INSTRDATA[$chan{instr}]{vib};
        $chan{mem_vibra}=$vibs;
        my ($vibspeed,$vibdepth) = (($vibs >> 4) & 0x0F, $vibs & 0x0F);
        my $vibnote = $chan{note} + sin($vibphase / $VIBLENGTH * 2 * 3.14159) * ($vibdepth/15);
        print_dp "= vibrato on %.1f, depth=%d speed=%d phase=%d/%d = %.1f; ",$chan{note},$vibdepth,$vibspeed,$vibphase,$VIBLENGTH,$vibnote;
        $chan{vibphase}+=$vibspeed; $chan{vibphase}%=$VIBLENGTH;
        if ($vibnote!=$chan{fxnote} || $vibnote!=$chan{note}) {
          $chan{fxnote}=$vibnote; # note to output, FX override
          $changed{note} = 1; # note changed
        }

      } elsif ($chan{command}==$IT_CMD_J_ARP || $INSTRDATA[$chan{instr}]{arp}) { # ARPEGGIO

        $chan{note} = $note->{note} if defined $note->{note}; # change if changed

        my $arpphase = int($chan{arpphase}+0.01)||0; # fix rounding errors
        if (defined $note->{note}) { $arpphase = 0; } # reset arpeggio phase on note change
        my $arps = $chan{command}==$IT_CMD_J_ARP ? ($chan{param} || $chan{mem_arp}) : $INSTRDATA[$chan{instr}]{arp};
        $chan{mem_arp}=$arps;
        my @arpn = (0, $arps >> 4, $arps & 0x0F);
        my $arpnote = $chan{note} + $arpn[$arpphase]; # leave the note unchanged, but add arpeggio
        print_dp "= arpeggio on %.1f, phase=%d +%d = %d; ",$chan{note},$arpphase,$arpn[$arpphase],$arpnote;
        $chan{arpphase}+=$ARPSPEED; if ($chan{arpphase}>3) { $chan{arpphase}-=3; }
        if ($chan{fxnote}!=$arpnote) {
          $chan{fxnote}=$arpnote; # note to output, FX override
          $changed{note} = 1; # note changed
        }

      } elsif (defined $note->{note}) { # play it straight

        $chan{note} = $note->{note} // $chan{note};
        delete $chan{fxnote};
        print_dp "= straight %.1f; ",$chan{note};
        $changed{note}=1;
      }

      # non-note effects      
      if ($chan{command}==$IT_CMD_D_VOLSL) {
        # starts immediately, not "on next tick" per spec. Sorry!
        my $vold = (($chan{param}>>4)&0x0F) - ($chan{param}&0x0F);
        my $vol = $chan{vol}+$vold; if ($vol>64) { $vol=64; } if ($vol<0) { $vol=0; }
        print_dp "= vol slide %d = %d; ", $vold, $vol;
        if ($vol!=$chan{vol}) {
          $chan{vol}=$vol; # note to output
          $changed{vol} = 1; # note changed
        }
      } elsif ($chan{command}==$IT_CMD_M_CHANVOL) {
        print_dp "= chanvol=%d; ",$chan{param};
        if ($chan{chanvol}!=$chan{param}) {
          $chan{chanvol}=$chan{param};
          if ($chan{note}>0) { $changed{vol}=1; }
        }
        delete $chan{command}; delete $chan{param}; # one-off
      }

      # magic noise
      # play borrow note on channel 3 when there's something changing on channel 2, and we're not repeating the magic
      if ($outchan==2
        && ($changed{note} || $changed{vol} || $changed{instr})
        && $INSTRDATA[$chan{instr}]{buzz}
        && ! (scalar @{$notedata[3]}
             && ($notedata[3][-1]{note}==$NOTE_BORROW_BUZZ && $notedata[3][-1]{vol}==$chan{vol})
             )
         ) {
        $chans[3]{note} = $NOTE_BORROW_BUZZ; $chans[3]{vol}=$chan{vol}; $chans[3]{override_note}=1; #just for debugs
        print_dp "= BUZZ override note=4 on channel 3; ";
        $chan{vol}=0; $changed{vol}=1;
      }
      if ($outchan==3 && $changed{note} && $pattern[$row][2]{note}->{note}<=0) { # note played on chan 4, nothing on chan 3 to override it
        delete $chan[4]{override_note}; #just for debugs
      }

      # clear some things
      if ($chan{command}!=$IT_CMD_H_VIB && !$INSTRDATA[$chan{instr}]{vib}) { delete $chan{vibphase}; }
      if ($chan{command}!=$IT_CMD_J_ARP && !$INSTRDATA[$chan{instr}]{arp}) { delete $chan{arpphase}; }

      if (keys %changed) {
        print_dp "changed: %s; ",join(",",map { "$_=$chan{$_}" } sort keys %changed);
      }

      # no more changes, just output

      if ($changed{note} || $changed{vol}) {
        push(@{$notedata[$outchan]}, {
          length => 1, # so far
          note => $chan{fxnote}//$chan{note},
          vol  => $chan{vol} * ($chan{chanvol}//64)/64 * $GLOBALVOL/128,
          magicsource => $note->{magicsource}
        });
        print_dp "new %.1f_%02d [%d:%d]\n",$notedata[$outchan][-1]{note},$notedata[$outchan][-1]{vol},$outchan+1,scalar @{$notedata[$outchan]}+1;
      } else {
        $notedata[$outchan][-1]{length}++;
        print_dp "old %.1f_%02d=%d [%d:%d]\n",$notedata[$outchan][-1]{note},$notedata[$outchan][-1]{vol},$notedata[$outchan][-1]{length},$outchan+1,scalar @{$notedata[$outchan]}+1;
      }
      
      %{$chans[$outchan]} = %chan;
    }
  }
  $row_ticks -= int($row_ticks);
}

trim_trailing_rests();

###################################################################
# Notes and rests are ready in $notedata

print "Pass 4: Converting to AGI data\n";

for (my $voice=0; $voice<$NUMCH; $voice++) {
  if ($DEBUG_AGI) { print("====================================================\n"); }
  printf " - Channel %d (%s), %d notes\n",$voice+1,$voice<=2&&"voice"||"noise",scalar(@{$notedata[$voice]});
  $prev_dur_frac=0;
  for (my $in=0; $in<scalar(@{$notedata[$voice]}); $in++) {
    $note=$notedata[$voice][$in]{note}; # if ($DEBUG_AGI) { printf("n:%6.2f  ",$note); }
    $length=$notedata[$voice][$in]{length};# if ($DEBUG_AGI) { printf("l:%3d  ",$length); } # length in ticks
    $vol=$notedata[$voice][$in]{vol}; if (!defined($vol) || $vol>63) { $vol=63; }

    #if ($length==0) { next; } # skip zero-length notes

    # prepare duration

    #$duration_f = $length / $AGI_TICK;
    #$out_duration = int($duration_f + $prev_dur_frac + 0.5); if ($out_duration<1) { $out_duration=1; }
    #$prev_dur_frac = $duration_f - $out_duration; # used in 'exact' tempo mode
    $out_duration = $length;
    
    # prepare frequency
    
    $freq=$out_noisefreq=0;
    $vreg=$voice<<1;
    if ($voice<=2) { # voice channel
      while ($note>=0 && $note<45) { $note+=12; }
      $freq=(440.0 * exp(($note-69)*log(2.0)/12.0));  #thanks to Lance Ewing!
      #if ($voice==2 && $INSTRDATA[$notedata[$voice][$in]{instr}||99]{buzz}) { $freq=(440.0 * exp(($note-46.05)*log(2.0)/12.30)); } # +21.6
      if ($voice==2 && $notedata[$voice][$in]{magicsource}) { $freq=(440.0 * exp(($note-46.05)*log(2.0)/12.30)); } # +21.6
      if (int($freq)!=$freq) {
        if ($freq<int($freq)+0.5) {} else {$freq=int($freq)+1}
      }
      $out_freqdiv = $freq ? int(111860/$freq) : 0;
      if ($note==-1) { $freq=0; $out_freqdiv=0; }
      
      $out_fv = $out_freqdiv >> 4;
      $out_fc = 128 + ($vreg<<4) + ($out_freqdiv%16);
    
    } else { # noise channel
    
      # override drums
      if ($voice==3 && $FORMAT eq "MIDI" && !$NOMIDIREMAP) {
        if ($DRUMNOTES{$note}) { $note = $DRUMNOTES{$note}->{note}; }
        else { $note = $DRUMNOTES{999}->{note}; }
      }

      $out_noisetype = int($note/12)%2;
      $out_noisefreq = $note%4;
      if ($note==-1) { $out_noisetype=$out_noisefreq=0; }
      
      $out_fv = 0;
      $out_fc = 128 + 96 + ($out_noisetype<<2) + ($out_noisefreq);  # even octave: periodic, odd octave: noise. Notes = 3 noise types + 4th borrowed from channel 3
    }

    if ($note==-1) { $vol=0; } #rest
    $out_att=128 + (($vreg|1)<<4) + (15-($vol>>2));
    if ($vol<0) { # skip volume!?
      $out_att=0;
    }

    die "overflow f $out_fv" if ($out_fv<0 || $out_fv>255);  die "overflow v $out_fc" if ($out_fc<0 || $out_fc>255);
    die "overflow a $out_att areg $vreg ".(($vreg|1)<<4)." atten $out_atten" if ($out_att<0 || $out_att>255);

    $packet = pack("SCCC",$out_duration,$out_fv,$out_fc,$out_att);
    $snddata[$voice] = $snddata[$voice].$packet;
    
    if ($DEBUG_AGI) { printf("%4d: n=%5.1f/%s v=%3d  d=%3d  =  %02x %02x %02x %02x %02x\n",
     $in,
     $note, $voice<=2 && sprintf("%6.1fHz",$freq) || ($note==-1?"------- ":sprintf("%4s,%2s ",qw(buzz hiss)[$out_noisetype],qw(hi md lo c2)[$out_noisefreq])), $vol, $out_duration,
     ord(substr($packet,0,1)),ord(substr($packet,1,1)),$out_fv,$out_fc,$out_att); }
  }
}

print "Writing AGI sound file to $outfile\n";
open(FILE,">".$outfile);
binmode(FILE);

print FILE "\x08\x00";
$fpos=8;

for ($ch=0;$ch<3;$ch++) {
  if (length($snddata)%5!=0) { die("ERROR: Channel $ch output has wrong length\n"); }
  $fpos+=length($snddata[$ch])+2;
  print FILE pack("S",$fpos);
}
for ($ch=0;$ch<4;$ch++) {
  print FILE $snddata[$ch];
  print FILE "\xFF\xFF";
}
print FILE "\xFF\xFF";

#$estl=16+length($snddata[0])+length($snddata[1])+length($snddata[2]);

close(FILE);
print "Wrote file: $outfile\n";










sub parse_instr_name {
  $ins = shift @_;
  $name = shift @_;

  if ($name =~ /\[(.+?)\]/) {
    my $agiflag = $1; # Captures the string inside [...]
    if ($agiflag =~ /SHIFT([0-9\.\+\-]+)/) {
      $INSTRDATA[$ins]{shift}=0+$1;
    }
    if ($agiflag =~ /NOISE/) {
      $INSTRDATA[$ins]{noise}=1;
    } elsif ($agiflag =~ /BUZZ/) {
      $INSTRDATA[$ins]{buzz}=1;
    }
  }
  $INSTRDATA[$ins]{name}=$name;
}


sub trim_trailing_rests {
  for (my $outchan = 0; $outchan<$NUMCH; $outchan++) {
    # trim last note if it was a pause
    while (scalar(@{$notedata[$outchan]}) && $notedata[$outchan][-1]{note} == -1) {
      pop @{$notedata[$outchan]};
    }
  }
}

sub trim {
   return $_[0] =~ s/\A\s+|\s*\c@*\z//urg;
}
