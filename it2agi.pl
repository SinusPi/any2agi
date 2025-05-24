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

$NUMCH=4;

print "IT2AGI version 0.2\n";
print "(c) 1999-2000 Nat Budin - portions by Lance Ewing\n";
print "Fixes 2025 by Adam 'Sinus' Skawinski\n";
print "\n";
if($ARGV[0] eq "") {
  die ("To run IT2AGI, give the name of an Impulse Tracker module as an\nargument.\n\nStopped at");
}
$v = shift @ARGV;
if ($v eq "--debug-it") { $DEBUG_IT=1; $v = shift @ARGV; }
if ($v eq "--debug-agi") { $DEBUG_AGI=1; $v = shift @ARGV; }
if ($v eq "--debug-out") { $DEBUG_OUT=1; $v = shift @ARGV; }
$infile = $v;
open(INFILE, "<".$infile);
binmode(INFILE);

$outfile = shift @ARGV;
if (!$outfile) { $outfile=$infile; $outfile =~ s/\..+$/.AGS/; }

# READING

read(INFILE,$buf,4);
if ($buf ne "IMPM") {
  die("Invalid IT header in file!  Stopped");
}

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
  seek(INFILE,$patoff[$orders[$order]],0);
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
    if ($DEBUG_IT) { print(sprintf("0x%X", tell(INFILE)-1)." = next row: $row\n"); }
    next READER;
  }
  $channel = ($cvar - 1) & 63;
    if ($DEBUG_IT) { print("chan $channel\n"); }
  $pmvar = $chanmask[$channel];
  if ($cvar & 128) {
    read(INFILE,$buf,1);
    $mvar = unpack("C",$buf);
    if ($DEBUG_IT) { print(sprintf("0x%X", tell(INFILE)-1)." = mvar $mvar\n"); }
  }
  else {
    $mvar = $pmvar;
    if ($DEBUG_IT) { print("pmvar $mvar\n"); }
  }
  $chanmask[$channel]=$mvar;

  if ($mvar & 16) {
    $pattern[$arow][$channel]{note} = $lastval[$channel]{note};
    if ($DEBUG_IT) { print($arow.": WTF? ch".$channel." n prev\n"); }
  }
  if ($mvar & 32) {
    $pattern[$arow][$channel]{instrument} = $lastval[$channel]{instrument};
  }
  if ($mvar & 64) {
    $pattern[$arow][$channel]{volpan} = $lastval[$channel]{volpan};
    if ($DEBUG_IT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." REv ".$lastval[$channel]{volpan}."\n"); }
  }
  if ($mvar & 128) {
    $pattern[$arow][$channel]{command} = $lastval[$channel]{command};
    $pattern[$arow][$channel]{param} = $lastval[$channel]{param};
  }

  if ($mvar & 1) {
    read(INFILE,$buf,1);
    $lastval[$channel]{note} = $pattern[$arow][$channel]{note} = unpack("C",$buf);
    if ($DEBUG_IT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." n ".unpack("C",$buf)."\n"); }
  }
  if ($mvar & 2) {
    read(INFILE,$buf,1);
    $lastval[$channel]{instrument} = $pattern[$arow][$channel]{instrument} = unpack("C",$buf);
    if ($DEBUG_IT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." i ".unpack("C",$buf)."\n"); }
  }
  if ($mvar & 4) {
    read(INFILE,$buf,1);
    $lastval[$channel]{volpan} = $pattern[$arow][$channel]{volpan} = unpack("C",$buf);
    if ($DEBUG_IT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." v ".unpack("C",$buf)."\n"); }
  }
  if ($mvar & 8) {
    read(INFILE,$buf,2);
    ($pattern[$arow][$channel]{command},
     $pattern[$arow][$channel]{param}) = unpack("CC",$buf);
    $lastval[$channel]{command}=$pattern[$arow][$channel]{command};
    $lastval[$channel]{param}=$pattern[$arow][$channel]{param};
    if ($DEBUG_IT) { print(sprintf("0x%X", tell(INFILE)-1)." = ".$arow.": ch".$channel." cp ".unpack("CC",$buf)."\n"); }
  }
}
}
close(INFILE);

$rows=$arows;

print "Pass 2: Finding Note Lengths\n";
for ($channel=0; $channel<$NUMCH; $channel++) {
  $nn=0;
  for ($row=0; $row<$rows; $row++) {
    $note=$pattern[$row][$channel]{note};
    if($note>0 && $note<120) { #exclude cuts and offs
      if ($DEBUG_NOTES) { print($pattern[$row][$channel]{row}.",".$pattern[$row][$channel]{note}.",".$pattern[$row][$channel]{length}.",".$pattern[$row][$channel]{volpan}."\n"); }
        $notelen=-1; 
        $srchrow=$row+1;
        NOTESEARCH: while ($srchrow<$rows) {
          if($pattern[$srchrow][$channel]{note}) {
#if ($channel==1) { print("$row note $note, found end at $srchrow: ".$pattern[$srchrow][$channel]{note}."\n"); }
            $notelen=$srchrow-$row;
            last NOTESEARCH;
          }
          $srchrow++;
        }
        if ($notelen==-1) {
          $notelen=$rows-$row;
        }
        $volpan=$pattern[$row][$channel]{volpan};

        $tunedata[$channel][$nn]{row} = $row;
        $tunedata[$channel][$nn]{note} = $note;
        $tunedata[$channel][$nn]{length} = $notelen;
        $tunedata[$channel][$nn]{volpan} = $volpan;
        $nn++;
    }
    $tunelen[$channel] = $nn;
  }
}

print "Pass 3: Inserting rests\n";
for ($channel=0; $channel<$NUMCH; $channel++) {
  $in=0;
  for ($nn=0; $nn<$tunelen[$channel]; $nn++) {
    if ($nn==0) {
      if ($tunedata[$channel][0]{row} == 0) {
        $notedata[$channel][$in]{note} = $tunedata[$channel][0]{note};
        $notedata[$channel][$in]{length} = $tunedata[$channel][0]{length};
        $notedata[$channel][$in]{volpan} = $tunedata[$channel][0]{volpan};
        $in++;
      }
      else {
        $notedata[$channel][$in]{note} = -1;
        $notedata[$channel][$in]{length} = $tunedata[$channel][0]{row};
        $in++;
        $notedata[$channel][$in]{note} = $tunedata[$channel][0]{note};
        $notedata[$channel][$in]{length} = $tunedata[$channel][0]{length};
        $notedata[$channel][$in]{volpan} = $tunedata[$channel][0]{volpan};
        $in++;
      }
    }
    else {
      if ($tunedata[$channel][$nn]{row} - ($tunedata[$channel][$nn-1]{row}+$tunedata[$channel][$nn-1]{length}) == 0) {
        $notedata[$channel][$in]{note} = $tunedata[$channel][$nn]{note};
        $notedata[$channel][$in]{length} = $tunedata[$channel][$nn]{length};
        $notedata[$channel][$in]{volpan} = $tunedata[$channel][$nn]{volpan};
        $in++;
      }
      else {
        $notedata[$channel][$in]{note} = -1; #sinus: -1
        $notedata[$channel][$in]{length} = $tunedata[$channel][$nn]{row} - ($tunedata[$channel][$nn-1]{row}+$tunedata[$channel][$nn-1]{length});
        $in++;
        $notedata[$channel][$in]{note} = $tunedata[$channel][$nn]{note};
        $notedata[$channel][$in]{length} = $tunedata[$channel][$nn]{length};
        $notedata[$channel][$in]{volpan} = $tunedata[$channel][$nn]{volpan};
        $in++;
      }
    }
  }
  $notelen[$channel]=$in;
}

$tempo=$it;
$speed=$is;
$durmul=9*($speed/8)*(140/$tempo);
if (int($durmul)!=$durmul) {
  if ($durmul<int($durmul)+0.5) {$durmul=int($durmul)} else {$durmul=int($durmul)+1}
}

print "Pass 4: Converting to AGI data\n";
for ($voice=0; $voice<$NUMCH; $voice++) {
 if ($DEBUG_AGI) { print("Voice: ".$voice." ================================\n"); }
  for ($in=0; $in<$notelen[$voice]; $in++) {
    $note=$notedata[$voice][$in]{note}; if ($DEBUG_AGI) { print("n: ".$note."  "); }
    $length=$notedata[$voice][$in]{length}; if ($DEBUG_AGI) { print("l: ".$length."  "); }
    $volpan=$notedata[$voice][$in]{volpan}; if (!$volpan) { $volpan=64; };
    $vol=15;
    if ($volpan==64) { $volpan=63; }
    if ($volpan<=63) { $vol=$volpan>>2; }
    if ($note==-1) { $vol=0; }
    if ($DEBUG_AGI) { print("v: ".$vol."  "); }

    $freq=(440.0 * exp(($note-69)*log(2.0)/12.0));  #thanks to Lance Ewing!
    if (int($freq)!=$freq) {
      if ($freq<int($freq)+0.5) {} else {$freq=int($freq)+1}
    }
    
    $bytes={" "," "," "," "," "};
    
    $dur=$length*$durmul;
    $d=int($dur >> 8);
    $d2=$dur % 256;
    if ($DEBUG_AGI) { print("d".$d." "); }
    if ($DEBUG_AGI) { print("D".$d2." "); }
    $bytes[0]=chr($d2); # buf
    $bytes[1]=chr($d);  # buf
    
    if ($note==-1) { $freqdiv=0; } else { $freqdiv=int(111860/$freq); }
    $vreg=0;
    if ($voice==0) {$vreg=0}
    if ($voice==1) {$vreg=2}
    if ($voice==2) {$vreg=4}
    if ($voice==3) {$vreg=6}
    $f=$freqdiv >> 4;
    $v=128+($vreg<<4)+($freqdiv%16);
    if ($voice==3) { $f=0; $v = 128 + 96 + 4*(int($note/12)%2) + ($note%4); } # even octave: periodic, odd octave: noise. Notes = 4 noise types.
    die "overflow f $f" if ($f<0 || $f>255);
    die "overflow v $v" if ($v<0 || $v>255);
    if ($DEBUG_AGI) { print("f".$f." "); }
    if ($DEBUG_AGI) { print("v".$v." "); }
    $bytes[2]=chr($f); # buf
    $bytes[3]=chr($v); # buf

    $atten=15-$vol;
    $areg=$vreg+1;
    $a=128+($areg<<4)+$atten;
    die "overflow a $a areg $areg ".($areg<<4)." atten $atten" if ($a<0 || $a>255);
    if ($DEBUG_AGI) { print("a".$a." "); }
    $bytes[4]=chr($a); # buf

    $an=$bytes[0].$bytes[1].$bytes[2].$bytes[3].$bytes[4];
    $snddata[$voice] = $snddata[$voice].$an;
    
    if ($DEBUG_AGI) { print("\n"); }
  }
  print (" - Channel ".($voice+1).", ".$notelen[$voice]." notes.\n");
}

print "Writing AGI sound file to $outfile\n";
open(FILE,">".$outfile);
binmode(FILE);

print FILE "\x08\x00";

$fpos=8;

for ($ch=0;$ch<$NUMCH-1;$ch++) {
  $fpos+=length($snddata[$ch])+2;
  $fbyte=chr($fpos%256);
  $sbyte=chr(int($fpos>>8));
  print FILE $fbyte.$sbyte;
}
for ($ch=0;$ch<$NUMCH;$ch++) {
  print FILE $snddata[$ch];
  print FILE "\xFF\xFF";
}
print FILE "\xFF\xFF";

#$estl=16+length($snddata[0])+length($snddata[1])+length($snddata[2]);

close(FILE);
print "Wrote file: $outfile\n";
