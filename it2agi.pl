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
    AGI engine's 60 ticks per second, and 16.67 ms per tick.

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
 
END
;
  exit(0);
}


if ($ARGV[0] eq "" || $ARGV[0] eq "-h" || $ARGV[0] eq "--help") {
  print <<"USAGE";
IT2AGI version 0.4.0
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
  --instr-note x y - force instrument x to play only note
    y. Useful to force a drum-like instrument to play
    only valid AGI drum notes. Typical notes are 13 (high
    noise), 14 (middle noise) and 15 (low noise).
    Combined with --channels to properly map an input
    channel to the noise output, and --auto-drum-offs to
    make output drums shorter, this option can turn a
    typical "rhythm channel" in the input into proper
    noise channel output for AGI.
  --instr-shift x y - shift (transpose) instrument x by y
    semitones. Use when input samples were recorded in a
    weird pitch, and notes in the input were written to
    match that. Or, use +12 or -12 to transpose by an
    octave.
  --debug-input, --debug-proc, --debug-agi - verbose printout for debugging purposes.
  
Output file is created in the same directory as the input file, with the .AGS extension.
You can also specify a different output file name.

USAGE
;
  exit(1);
}

@CHANNELS=(1,2,3,4); $CHANNELS_DEFAULT=1;
$AGI_TICK = 16.66667; # ms
$POLYMODE = 0;
$DRUMNOTES = {
  35 => { note => 16, length => 100  }, # bass drum
  36 => { note => 16, length => 100 },  # bass drum 1
  37 => { note => 14, length => 50 },   # side stick
  38 => { note => 15, length => 100 },  # snare
  39 => { note => 15, length => 150 },  # clap
  40 => { note => 15, length => 100 },  # elec snare
  41 => { note => 14, length => 100 },  # low tom
  42 => { note => 14, length => 50 },  # hihat closed
  999 => { note => 16, length => 50 },  # hihat closed
};

while ($v = shift @ARGV) {
     if ($v eq "--debug-input") { $DEBUG_INPUT=1; }
  elsif ($v eq "--debug-proc") { $DEBUG_PROC=1; }
  elsif ($v eq "--debug-agi") { $DEBUG_AGI=1; }
  elsif ($v eq "--channels") { @CHANNELS = split(",",shift @ARGV); $CHANNELS_DEFAULT=0; }
  elsif ($v eq "--tempo-exact") { $tempomode_override="exact"; }
  elsif ($v eq "--auto-drum-offs") { $auto_drum_offs = shift @ARGV; }
  elsif ($v eq "--instr-note") { $instr = shift @ARGV; $note = shift @ARGV; $INSTRNOTE[$instr]=$note; }
  elsif ($v eq "--instr-shift") { $instr = shift @ARGV; $shift = shift @ARGV; $INSTRSHIFT[$instr]=$shift; }
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

sub print_di {
  if ($DEBUG_INPUT) {
    printf @_;
  }
}

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
  seek(INFILE,4,0);
  read(INFILE,$songname,26);
  print "Reading module '$songname' from $infile\n";

  read(INFILE,$buf,2);
  read(INFILE,$buf,15);
  ($ordnum, $insnum, $smpnum, $patnum,
  $cwtv,   $cmwt,   $flags) = unpack("S6b8",$buf);
  read(INFILE,$buf,1);
  $special=unpack("b8",$buf);

  ($stereo, $mixopt, $useins, $linear, $oldfx,  $linkfx, $usemid, $reqmid)
        = split("",$flags);
  ($incmsg, $dum1,   $dum2,   $midcfg, $dum3,   $dum4,   $dum5,   $dum6)
        = split("",$special);

  read(INFILE,$buf,16);
  ($gv, $mv, $is, $it, $sep, $pwd, $msglgth, $msgoffset, $dum1)
        = unpack("C6SI2",$buf);

  read(INFILE,$buf,64);
  @chnlpan=unpack("C64",$buf);

  read(INFILE,$buf,64);
  @chnlvol=unpack("C64",$buf);

  read(INFILE,$buf,$ordnum);
  @orders=unpack("C$ordnum",$buf);

  read(INFILE,$buf,$insnum*4+$smpnum*4);
  read(INFILE,$buf,$patnum*4);
  @patoff=unpack("I$patnum",$buf);

  print "Pass 1: Reading IT Data\n";

  $arow=0;
  $arows=0;

  $IT_CMD_J_ARP = 10;

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
        $pattern[$arow][$channel]{instrument} = $lastval[$channel]{instrument};
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
        $lastval[$channel]{instrument} = $pattern[$arow][$channel]{instrument} = unpack("C",$buf);
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
      print_di "0x%X = %s ch%d: n=%d i=%d v=%d c=%d p=%d\n",
        tell(INFILE)-1,
        $mvar&1 ? "note" : "",
        $channel,
        $pattern[$arow][$channel]{note} || 0,
        $pattern[$arow][$channel]{instrument} || 0,
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
  print("Reading Protracker module '$title'...\n");
  # samples, ignore
  for (my $sn=0;$sn<31;$sn++) {
    read(INFILE,my $sname,22);
    read(INFILE,my $slen,2);
    read(INFILE,my $stune,1);
    read(INFILE,my $svol,1);
    read(INFILE,my $reps,2);
    read(INFILE,my $repl,2);
    print_di "S%02d: %s\n",$sn,$sname;
  }
  read(INFILE,$_,1); $songlen=unpack("C");
  read(INFILE,$_,1);
  read(INFILE,$_,128); @songpats = unpack("C*",substr($_,0,$songlen));
  read(INFILE,$mk,4); if ($mk!="M.K.") { die("MOD broken! $mk\n"); }

  # my $maxpat=0; for (my $i=0;$i<128;$i++) { my $p=ord(substr($songpats,$i,1)); $maxpat=$p if ($p>$maxpat); }

  print_di "Song length: %d, patterns: %s\n",$songlen,join(",",@songpats);

  $it=120; $is=6;

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
        $samplenum = ($b1&0xF0) | ($b3>>4);
        $period = (($b1&0x0F)<<8) | $b2;
        $command = $b3&0x0F;
        $args = $b4;
        if (!$samplenum && !$period && !$command) {
          print_di "        ";
          next;
        }
        $note = $periodtonote{$period} || -1;
        if ($note>0 && $INSTRSHIFT[$samplenum])  { $note+=$INSTRSHIFT[$samplenum]; }
        if ($note>0 && $INSTRNOTE[$samplenum]) { $note=$INSTRNOTE[$samplenum]; }
        $notedata = { note=>$note };
        if ($command==0x0C) { $notedata->{volpan}=$args; }
        $pattern[$arow+$row][$chan] = $notedata;
        
        print_di "%02d %1X%02x  ",$periodtonote{$period},$command,$args
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

  if ($CHANNELS_DEFAULT) { @CHANNELS=(0,1,2,9); } # default channels

  my $miditempo = 500000; # default tempo
  my $miditicksbeat = 192; # default ticks per beat
  
  my $MIDICH_DRUM = 9; # default drum channel

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
              undef $last[$chan];
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

if (@pattern) {
  $tunedata=[];

  print "Using channels ".join(",",@CHANNELS)."\n";

  print "Pass 2: Finding Note Lengths\n";

  $tempomode = $tempomode_override || "even";
  
  $tempo=$it;
  $speed=$is;
  $rowdur_ms = (2500 / $it) * $is;
  printf "Using tempo %d speed %d, 'classic' tempo: 1 row = %.2f ms\n",$it,$is,$rowdur_ms;
  if ($tempomode eq "even") {
    $rowdur_agi = 1000/60;
    $mul = int($rowdur_ms/$rowdur_agi + 0.5); if ($mul<1) { $mul=1; }
    $rowdur_ms = $mul*$rowdur_agi;
    printf "Tempo mode is 'even', row = %d AGI ticks (%.2f ms)\n",$mul,$rowdur_ms;
  } else {
    print "Tempo mode is 'exact', row playback may be uneven.\n";
  }

  $arows = $#pattern+1;

  for (my $outchan=0; $outchan<$NUMCH; $outchan++) {
    $tunedata[$outchan] = [];
    $channel = $CHANNELS[$outchan]-1;
    for ($row=0; $row<$arows; $row++) {
      $note=$pattern[$row][$channel];
      if($note->{note}>0 && $note->{note}<120) { #exclude cuts and offs
        $notelen=$arows-$row; # assume no end
        $srchrow=$row+1;
        NOTESEARCH: while ($srchrow<$arows) {
          if($pattern[$srchrow][$channel]{note}) {
            #if ($channel==1) { print("$row note $note, found end at $srchrow: ".$pattern[$srchrow][$channel]{note}."\n"); }
            $notelen=$srchrow-$row;
            last NOTESEARCH;
          }
          $srchrow++;
        }
        
        my $start = $row*$rowdur_ms;
        my $length = $notelen*$rowdur_ms;

        my $pauselength;
        my $drumticks = $auto_drum_offs*$AGI_TICK;
        if ($outchan==3 && $auto_drum_offs && $length>$DRUMTICKS+1) { ($length,$pauselength) = ($drumticks, $length - $drumticks); }

        push @{$tunedata[$outchan]}, { note => $note->{note}, vol => $note->{volpan},   row => $row, rows => $notelen,    start => $start, length => $length,   instrument => $note->{instrument}, command => $note->{command}, param => $note->{param} };
        if ($pauselength) { push @{$tunedata[$outchan]}, { note => 0, vol => 0,   row => $row, rows => $notelen,    start => $start+$length, length => $pauselength }; }
        
        #if (1) { print($row.",".$pattern[$row][$channel]{note}.",".$pattern[$row][$channel]{rows}.",".$pattern[$row][$channel]{volpan}."\n"); }
        #printf ("%.2f %.2f\n",$row*$rowdur_ms,$notelen*$rowdur_ms);
      }
    }
  }
} else {

  if ($DEBUG_PROC) {
    print "\n MIDI:\n";
    for (my $midichan=0; $midichan<32; $midichan++) {
      printf "MIDI Channel %d:\n",$midichan;
      for (my $nn=0; $nn<scalar(@{$mididata[$midichan]}); $nn++) {
        my $no=$mididata[$midichan][$nn];
        printf "%3d. start %6.2f, len %6.2f, note %d\n",$nn,$no->{start},$no->{length},$no->{note};
      }
    }
  }

  # MIDI!
  for (my $outchan=0; $outchan<$NUMCH; $outchan++) {
    $inchan = $CHANNELS[$outchan];
    printf "MIDI channel %d maps to output %d, %d notes\n",$inchan,$outchan+1,scalar(@{$mididata[$inchan]});
    $mididata[$inchan] = [ sort { $a->{start} <=> $b->{start} } @{$mididata[$inchan]} ];
    $tunedata[$outchan] = $mididata[$inchan];

    # PREVENT OVERLAPS
    for (my $nn=1; $nn<scalar(@{$tunedata[$outchan]}); $nn++) {
      my $current_note = $tunedata[$outchan][$nn];
      my $previous_note = $tunedata[$outchan][$nn-1];

      if ($previous_note->{start} + $previous_note->{length} > $current_note->{start}) { $previous_note->{length} = $current_note->{start}-$previous_note->{start}; }
    }
  }

}

if ($DEBUG_PROC) {
  print "\n";
  for (my $outchan=0; $outchan<$NUMCH; $outchan++) {
    printf "Channel %d:\n",$outchan+1;
    for ($nn=0; $nn<scalar(@{$tunedata[$outchan]}); $nn++) {
      $no=$tunedata[$outchan][$nn];
      printf "%3d. start %6.2f, len %6.2f, note %d\n",$nn,$no->{start},$no->{length},$no->{note};
    }
  }
}

#############################################################################################################
# Here we're expecting to have $tunedata[channel][]{row,note,rows,vol,start,length} to insert rests between notes.

print "Pass 3: Inserting rests and effects\n";
$notedata = [];
for ($channel=0; $channel<$NUMCH; $channel++) {
  $notedata[$channel] = [];
  for ($nn=0; $nn<scalar(@{$tunedata[$channel]}); $nn++) {
    if ($nn==0) {
      my $first_note = $tunedata[$channel][0];
      if ($first_note->{start} > 0) {
        push @{$notedata[$channel]}, { note => -1, length => $first_note->{start} };
      }
      push @{$notedata[$channel]}, $first_note;
    }
    else {
      my $current_note = $tunedata[$channel][$nn];
      my $previous_note = $tunedata[$channel][$nn-1];

      # PREVENT OVERLAPS
      #if ($previous_note->{start} + $previous_note->{length} > $current_note->{start}) { $previous_note->{length} = $current_note->{start}-$previous_note->{start}; }

      if ($current_note->{start} - ($previous_note->{start} + $previous_note->{length}) >= $AGI_TICK/2) {
        push @{$notedata[$channel]}, { note => -1, length => $current_note->{start} - ($previous_note->{start} + $previous_note->{length}) };
      }
      push @{$notedata[$channel]}, $current_note;
    }
  }
}

###################################################################
# Notes and rests are ready in $notedata

print "Pass 4: Converting to AGI data\n";

for ($voice=0; $voice<$NUMCH; $voice++) {
  if ($DEBUG_AGI) { print("====================================================\n"); }
  printf " - Channel %d (%s), %d notes\n",$voice+1,$voice<=2&&"voice"||"noise",scalar(@{$notedata[$voice]});
  $prev_dur_frac=0;
  for ($in=0; $in<scalar(@{$notedata[$voice]}); $in++) {
    $note=$notedata[$voice][$in]{note}; if ($DEBUG_AGI) { printf("n:%3d  ",$note); }
    $length=$notedata[$voice][$in]{length}; if ($DEBUG_AGI) { printf("l:%7.1f  ",$length); } # length as time in ms
    $vol=$notedata[$voice][$in]{vol}; if (!defined($vol) || $vol>63) { $vol=63; }

    #if ($length==0) { next; } # skip zero-length notes

    # prepare duration

    $duration_f = $length / $AGI_TICK;
    $out_duration = int($duration_f + $prev_dur_frac + 0.5); if ($out_duration<1) { $out_duration=1; }
    $prev_dur_frac = $duration_f - $out_duration; # used in 'exact' tempo mode
    
    # prepare frequency
    
    $freq=$out_noisefreq=0;
    $vreg=$voice<<1;
    if ($voice<=2) { # voice channel
      while ($note>=0 && $note<45) { $note+=12; }
      $freq=(440.0 * exp(($note-69)*log(2.0)/12.0));  #thanks to Lance Ewing!
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
        if ($DRUMNOTES[$note]) { $note = $DRUMNOTES[$note]{note}; }
        else { $note = $DRUMNOTES[999]{note}; }
      }

      $out_noisetype = int($note/12)%2;
      $out_noisefreq = $note%4;
      if ($note==-1) { $out_noisetype=$out_noisefreq=0; }
      
      $out_fv = 0;
      $out_fc = 128 + 96 + ($out_noisetype<<2) + ($out_noisefreq);  # even octave: periodic, odd octave: noise. Notes = 3 noise types + 4th borrowed from channel 3
    }

    if ($note==-1) { $vol=0; } #rest
    $out_att=128 + (($vreg|1)<<4) + (15-($vol>>2));

    die "overflow f $out_fv" if ($out_fv<0 || $out_fv>255);  die "overflow v $out_fc" if ($out_fc<0 || $out_fc>255);
    die "overflow a $out_att areg $vreg ".(($vreg|1)<<4)." atten $out_atten" if ($out_att<0 || $out_att>255);

    $packet = pack("SCCC",$out_duration,$out_fv,$out_fc,$out_att);
    $snddata[$voice] = $snddata[$voice].$packet;
    
    if ($DEBUG_AGI) { printf(" = d %3d f %4d v %3d = %02x %02x %02x %02x %02x\n",$out_duration,$voice<=2 && $freq || $out_noisetype*10+$out_noisefreq,$vol,ord(substr($packet,0,1)),ord(substr($packet,1,1)),$out_fv,$out_fc,$out_att); }
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
