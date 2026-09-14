alias prop="rm .DS_Store; /usr/local/bin/propolis --metadata-root=/Users/olex/.propolis ."
alias downsample24="bash /Users/olex/code/reduct/downsampler-threaded-main/downsampler-threaded.sh -d 'dither -s' -- *.flac"

export RRPATH="/Users/olex/code/reduct/red-filenamer"
alias rrename="tsc --esModuleInterop --moduleResolution nodenext --outDir $RRPATH/dist $RRPATH/src/*; node $RRPATH/dist/red-filenamer.js"
alias rtorr="tsc --esModuleInterop --moduleResolution nodenext --outDir $RRPATH/dist $RRPATH/src/*; node $RRPATH/dist/red-torrentmaker.js"
alias rxld="tsc --esModuleInterop --moduleResolution nodenext --outDir $RRPATH/dist $RRPATH/src/*; node $RRPATH/dist/red-xldcleanup.js"

function movetosoyuz () {
  echo rclone copy "./$@" soyuz:"files/$@"
  rclone copy --verbose "./$@" soyuz:"files/$@"
}
