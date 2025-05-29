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
 0.3.0: proper MIDI support, with tempo changes and cutting overlapped notes
 0.4.0: MIDI support has drummaps now
 
