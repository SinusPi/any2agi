#!/usr/bin/perl

# Unix users: if your Perl directory is different than the one
# mentioned above, change the line above to reflect your system
# setup.
#
###############################################################
#         Impulse Tracker -> AGI Sound Converter              #
#                      by Nat Budin                           #
###############################################################
#
# Before running IT2AGI, make sure you have Perl 5 or above
# installed on your computer.  Unix users probably already have
# it.  Windows users can get a free Win32 implementation at:
#
# http://www.activestate.com
#
# To use this program, just type "perl it2agi xxxxxxx.it" where
# xxxxxxx.it is the name of the Impulse Tracker 2.14 file you
# want to convert.  IT2AGI will automatically spit out a file
# called xxxxxxx.ags (where xxxxxxx is the same name as your IT
# file), which is in AGI Sound format.  You can import it into
# your AGI game using AGI Studio 1.3 or higher.
#
# Sinus 2025-05-19: You can now add another parameter, giving
# the destination filename, so that you can immediately name
# your output like "SOUND.123" which makes it easier to import
# into AGI Studio.
#
# To make an Impulse Tracker file, you'll need Impulse Tracker
# 2.14 or higher.  To download it, go to this web site:
#
# http://www.noisemusic.org/it
#
# Alternatively, you can use another compatible tracker.  My
# personal favorite is ModPlug Tracker.  To download that, go
# to the web site:
#
# http://www.modplug.org
#
# Sinus 2025-05-19: These days, ModPlug Tracker became
# OpenModPlugTracker, found at https://openmpt.org .
#
# Many thanks go to Lance Ewing.  Not only did he write the
# AGI Sound specification, enabling me to write this program,
# I also stole a formula off his ROL2SND program.  So, thanks
# Lance!
#
# If you have any problems running this program (and you will,
# I'm sure), please contact me.  You can email me at:
#
# natbudin@newmail.net
#
# Also, if any of you Perl programmers out there spot a bug
# that you think you can fix, email me the bugfix.  You will
# get my undying gratitude and proper credit in the next
# version.
#
# Thanks for using IT2AGI!
#
# Sinus takes over:
#
# 0.2.1: Added recognizing MOD, S3M and XM modules, and MIDI
#        files. They're not (yet?) supported, but recognized.
# 0.2.2: Experimental option --channels added
# 0.2.3: Tempo mode added: --tempo-exact
# 0.2.4: Auto drum note-offs added: --auto-drum-offs 1/2/3...
# 0.2.5: very basic MOD and MIDI support added
# 
###############################################################
#    Notes on making IT2AGI-compliant Impulse Tracker files   #
###############################################################
#
# Things to remember:
#
# 1) IT2AGI uses only the first three channels of an Impulse
#    Tracker file.  These are mapped to the three voices of the
#    PCjr sound chip.
#
#    Sinus 2025-05-19: The fourth channel is now used as noise
#    voice, in which every even/odd octave denotes the noise
#    type (random/deterministic), and notes pick between
#    4 noise frequencies.
#
# 2) IT2AGI doesn't (yet) support changing tempo or speed in
#    the middle of the song.  Don't try this, as it will be
#    cruelly ignored.
#
# 3) Volumes aren't supported either, yet.  They will be in the
#    next version.  For now, everything is played full blast.
#
#    Sinus 2025-05-19: Volumes are now supported.
#
# 4) Finally, AGI is very limited in what it can do.  If AGI
#    doesn't support something, IT2AGI most likely doesn't
#    either.
#
# Oh, and one more: have fun.

@CHANNELS=(1,2,3,4);

print "IT2AGI version 0.2.5\n";
print "(c) 1999-2000 Nat Budin - portions by Lance Ewing\n";
print "Fixes 2025 by Adam 'Sinus' Skawinski\n";
print "\n";
if($ARGV[0] eq "") {
  die ("To run IT2AGI, give the name of an Impulse Tracker module as an\nargument.\n\nStopped at");
}
while ($v = shift @ARGV) {
     if ($v eq "--debug-input") { $DEBUG_INPUT=1; }
  elsif ($v eq "--debug-proc") { $DEBUG_PROC=1; }
  elsif ($v eq "--debug-agi") { $DEBUG_AGI=1; }
  elsif ($v eq "--channels") { @CHANNELS = split(",",shift @ARGV); }
  elsif ($v eq "--tempo-exact") { $tempomode_override="exact"; }
  elsif ($v eq "--auto-drum-offs") { $auto_drum_offs = shift @ARGV; }
  else {
    if (!$infile) { $infile = $v; } else { $outfile = $v; }
  }
}

$NUMCH=$#CHANNELS+1;


open(INFILE, "<".$infile);
binmode(INFILE);

if (!$outfile) { $outfile=$infile; $outfile =~ s/\..+$/.AGS/; }

print("Input: $infile  Output: $outfile\n");

# READING

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
        if ($DEBUG_INPUT) { print(sprintf("0x%X", tell(INFILE)-1)." = next row: $row\n"); }
        next READER;
      }
      $channel = ($cvar - 1) & 63;
        if ($DEBUG_INPUT) { print("chan $channel\n"); }
      $pmvar = $chanmask[$channel];
      if ($cvar & 128) {
        read(INFILE,$buf,1);
        $mvar = unpack("C",$buf);
        if ($DEBUG_INPUT) { print(sprintf("0x%X", tell(INFILE)-1)." = mvar $mvar\n"); }
      }
      else {
        $mvar = $pmvar;
        if ($DEBUG_INPUT) { print("pmvar $mvar\n"); }
      }
      $chanmask[$channel]=$mvar;

      if ($mvar & 16) {
        $pattern[$arow][$channel]{note} = $lastval[$channel]{note};
        # if ($DEBUG_INPUT) { print($arow.": WTF? ch".$channel." n prev\n"); }
      }
      if ($mvar & 32) {
        $pattern[$arow][$channel]{instrument} = $lastval[$channel]{instrument};
      }
      if ($mvar & 64) {
        $pattern[$arow][$channel]{volpan} = $lastval[$channel]{volpan};
        if ($DEBUG_INPUT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." REv ".$lastval[$channel]{volpan}."\n"); }
      }
      if ($mvar & 128) {
        $pattern[$arow][$channel]{command} = $lastval[$channel]{command};
        $pattern[$arow][$channel]{param} = $lastval[$channel]{param};
      }

      if ($mvar & 1) {
        read(INFILE,$buf,1);
        $lastval[$channel]{note} = $pattern[$arow][$channel]{note} = unpack("C",$buf);
        if ($DEBUG_INPUT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." n ".unpack("C",$buf)."\n"); }
      }
      if ($mvar & 2) {
        read(INFILE,$buf,1);
        $lastval[$channel]{instrument} = $pattern[$arow][$channel]{instrument} = unpack("C",$buf);
        if ($DEBUG_INPUT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." i ".unpack("C",$buf)."\n"); }
      }
      if ($mvar & 4) {
        read(INFILE,$buf,1);
        $lastval[$channel]{volpan} = $pattern[$arow][$channel]{volpan} = unpack("C",$buf);
        if ($DEBUG_INPUT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." v ".unpack("C",$buf)."\n"); }
      }
      if ($mvar & 8) {
        read(INFILE,$buf,2);
        ($pattern[$arow][$channel]{command},
        $pattern[$arow][$channel]{param}) = unpack("CC",$buf);
        $lastval[$channel]{command}=$pattern[$arow][$channel]{command};
        $lastval[$channel]{param}=$pattern[$arow][$channel]{param};
        if ($DEBUG_INPUT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." cp ".unpack("CC",$buf)."\n"); }
      }
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
    if ($DEBUG_INPUT) { printf "S%02d: %s\n",$sn,$sname; }
  }
  read(INFILE,$_,1); $songlen=unpack("C");
  read(INFILE,$_,1);
  read(INFILE,$_,128); @songpats = unpack("C*",substr($_,0,$songlen));
  read(INFILE,$mk,4); if ($mk!="M.K.") { die("MOD broken! $mk\n"); }

  # my $maxpat=0; for (my $i=0;$i<128;$i++) { my $p=ord(substr($songpats,$i,1)); $maxpat=$p if ($p>$maxpat); }

  if ($DEBUG_INPUT) { printf "Song length: %d, patterns: %s\n",$songlen,join(",",@songpats); }

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
    if ($DEBUG_INPUT) { print "reading pat ".$pat."\n"; }
    for (my $row=0;$row<$modpatlen;$row++) {
      if ($DEBUG_INPUT) { printf "%02d = ",$row; }
      for (my $chan=0;$chan<$modchannels;$chan++) {
        read(INFILE,$_,4); my ($b1,$b2,$b3,$b4) = unpack("CCCC");
        $samplenum = ($b1&0xF0) | ($b3>>4);
        $period = (($b1&0x0F)<<8) | $b2;
        $command = $b3&0x0F;
        $args = $b4;
        if (!$samplenum && !$period && !$command) {
          if ($DEBUG_INPUT) { printf "        "; }
          next;
        }
        $note = { note=>$periodtonote{$period} || -1 };
        if ($command==0x0C) { $note->{volpan}=$args; }
        $pattern[$arow+$row][$chan] = $note;
        
        if ($DEBUG_INPUT) { printf "%02d %1X%02x  ",$periodtonote{$period},$command,$args }
      }
      if ($DEBUG_INPUT) { print "\n"; }
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
  seek(INFILE,0,0);
  $chunks=0;
  do {
    read(INFILE,my $chunktype,4);
    read(INFILE,$_,4); $length = unpack("L>");
    read(INFILE,my $chunkbuf,$length);

    $midinotes=[];

    my @readchans;
    for (my $ch=0;$ch<$NUMCH;$ch++) { $readchans[$CHANNELS[$ch]]=1; }

    if ($chunktype eq "MThd") {
      ## read header
      my ($format,$ntrks,$div) = unpack("S>[3]",$buf);
      my $divtype = $div & 0x8000;
      if ($divtype==0) { $ticksperq = $div & 0x7FFF; }
      else { ($negsmpte,$ticksperf)=(($div & 0x7F00)>>8,($div & 0x00FF)); }
      if ($DEBUG_INPUT) { print("Header: format $format, $ntrks tracks, ticksperq=$ticksperq, negsmpte=$negsmpte, ticksperf=$ticksperf\n"); }
    } elsif ($chunktype eq "MTrk") {
      open(my $bufread,'<',\$chunkbuf);
      $tracks++;
      if ($DEBUG_INPUT) { print("Reading track $tracks, $length bytes\n"); }
      
      $totaltime=0;
      undef @last;

      do {{
        $delta = read_vlq($bufread);
        $totaltime+=$delta;

        printf "[%5d+%5d]: ",$totaltime,$delta;
        read($bufread,$_,1); $status=unpack("C",$_);
        if ($status&0x80) {
          printf ("Status %08b  ",$status);
        } else {
          $status=$oldstatus; seek($bufread,-1,1); # keep old status, go back a byte
          printf ("   ... %08b  ",$status);
        }
        $type=($status&0xF0)>>4;
        $chan=($status&0x0F);
        $oldstatus=$status;

           if ($type==0b1001) { read($bufread,$_,2); ($k,$v)=unpack("CC"); print("$chan N-ON $k=$v "); if (defined($last[$chan]) && $last[$chan]{note}!=$k) { $last[$chan]{length}=$totaltime-$last[$chan]{start}; push @{$mididata[$chan]}; }  $last[$chan] = { note=>$k, vol=>$v>>1, start=>$totaltime }; if ($DEBUG_INPUT) { print "<<."; } }
        elsif ($type==0b1000) { read($bufread,$_,2); ($k,$v)=unpack("CC"); print("$chan N-OF $k=$v "); if ($last[$chan]{note}==$k) { $last[$chan]{length} = $totaltime-$last[$chan]{start}; push @{$mididata[$chan]}, $last[$chan]; undef $last[$chan]; } if ($DEBUG_INPUT) { print "<<'"; } }
        elsif ($type==0b1010) { read($bufread,$_,2); ($k,$v)=unpack("CC"); print("$chan AFTT $k=$v "); }
        elsif ($type==0b1011) { read($bufread,$_,2); ($k,$v)=unpack("CC"); print("$chan CTRL $k=$v "); }
        elsif ($type==0b1100) { read($bufread,$_,1); $pc=unpack("C"); print("$chan PCHG $pc "); }
        elsif ($type==0b1101) { read($bufread,$_,1); $v=ord($_); print("$chan AFTC $k=$v "); }
        elsif ($type==0b1110) { read($bufread,$_,2); $v=ord($_); print("$chan PWHL $k=$v "); }
        elsif ($status==0b11110000) { print "SSX0 "; $len=read_vlq(); read($bufread,$buf,$len); printf("[%s]",$buf); } # do { read($bufread,$buf,1); } until (ord($buf)==0b11110111); }
        elsif ($status==0b11110111) { print "SSX1 "; $len=read_vlq(); read($bufread,$buf,$len); } # do { read($bufread,$buf,1); } until (ord($buf)==0b11110111); }
        elsif ($status==0b11110010) { read($bufread,$buf,2); }
        elsif ($status==0b11110011) { read($bufread,$buf,1); }
        elsif ($status==0b11111111) { # meta 
          read($bufread,$_,1); $meta=unpack("C",$_);
          printf("META%02x ",$meta);
             if ($meta==0x00) { read($bufread,$buf,1); printf("%02x SEQN",ord($buf)); }
          elsif ($meta<=0x07) { $len=read_vlq($bufread); read($bufread,$buf,$len); printf("[%s]",$buf); }
          elsif ($meta==0x20) { read($bufread,$buf,2); }
          elsif ($meta==0x21) { read($bufread,$buf,2); }
          elsif ($meta==0x2F) { read($bufread,$_,1); $v=unpack("C"); printf("%02x",$v); }
          elsif ($meta==0x51) { read($bufread,$_,4); ($v,$t1,$t2,$t3)=unpack("C4"); $t=($t1<<16)+($t2<<8)+$t3; printf("%02x TMPO %d",$v,$t); }
          elsif ($meta==0x54) { read($bufread,$buf,6); }
          elsif ($meta==0x58) { read($bufread,$buf,5); }
          elsif ($meta==0x59) { read($bufread,$_,3); ($v,$sf,$mi)=unpack("CcC"); printf("%02x SIGN %d %s",$v,$sf,($mi?"min":"maj")); }
          elsif ($meta==0x7f) { $len=read_vlq($bufread); read($bufread,$buf,$len); printf("[%s]",$buf); }
        }
        else { printf ("Unknown status %08b\n",$status); }
        print("\n");
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
      $note=$pattern[$row][$channel]{note};
      if($note>0 && $note<120) { #exclude cuts and offs
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
        $vol=$pattern[$row][$channel]{volpan};

        if ($outchan==3 && $auto_drum_offs && $notelen>$auto_drum_offs) { $notelen = $auto_drum_offs; }

        push @{$tunedata[$outchan]}, { note => $note, vol => $vol,   row => $row, rows => $notelen,    start => $row*$rowdur_ms, length => $notelen*$rowdur_ms };
        
        #if (1) { print($row.",".$pattern[$row][$channel]{note}.",".$pattern[$row][$channel]{rows}.",".$pattern[$row][$channel]{volpan}."\n"); }
        #printf ("%.2f %.2f\n",$row*$rowdur_ms,$notelen*$rowdur_ms);
      }
    }
  }
} else {
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
      printf "%3d. start %5d, len %5d, note %d\n",$nn,$no->{start},$no->{length},$no->{note};
    }
  }
}

#############################################################################################################
# Here we're expecting to have $tunedata[channel][]{row,note,rows,vol,start,length} to insert rests between notes.

print "Pass 3: Inserting rests\n";
$notedata = [];
for ($channel=0; $channel<$NUMCH; $channel++) {
  $notedata[$channel] = [];
  for ($nn=0; $nn<scalar(@{$tunedata[$channel]}); $nn++) {
    if ($nn==0) {
      my $first_note = $tunedata[$channel][0];
      if ($first_note->{start} == 0) {
        push @{$notedata[$channel]}, $first_note;
      }
      else {
        push @{$notedata[$channel]}, { note => -1, length => $first_note->{start} };
        push @{$notedata[$channel]}, $first_note;
      }
    }
    else {
      my $current_note = $tunedata[$channel][$nn];
      my $previous_note = $tunedata[$channel][$nn-1];

      # PREVENT OVERLAPS
      if ($previous_note->{start} + $previous_note->{length} > $current_note->{start}) { $previous_note->{length} = $current_note->{start}-$previous_note->{start}; }

      if ($current_note->{start} - ($previous_note->{start} + $previous_note->{length}) < 0.001) { # precise enough
        push @{$notedata[$channel]}, $current_note;
      } else {
        push @{$notedata[$channel]}, { note => -1, length => $current_note->{start} - ($previous_note->{start} + $previous_note->{length}) };
        push @{$notedata[$channel]}, $current_note;
      }
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

    # prepare duration

    $duration_f = $length / 16.66667;
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
