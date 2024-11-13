#!/usr/bin/env bash
src="sg0--nido"
out="$HOME/Logs/$src$1.log"
ulimit -s unlimited
printf "" > "$out"

# Download source code
if [[ "$DOWNLOAD" != "0" ]]; then
  rm -rf $src
  git clone https://github.com/wolfram77/$src
  cd $src
fi

# Compile the source code
make clean
make -j32
wget https://github.com/wolfram77/ECP-ExaGraph--vite/releases/download/1.0.0/fileConvert
chmod +x fileConvert

# Convert graph to edgelist, run Nido, and clean up
runNido() {
  stdbuf --output=L printf "Converting $1 to $1.bin ...\n"        | tee -a "$out"
  stdbuf --output=L ./fileConvert -m -w -f "$1" -o "$1.bin"  2>&1 | tee -a "$out"
  stdbuf --output=L ./run_1_70 -f "$1.bin"                   2>&1 | tee -a "$out"
  stdbuf --output=L printf "\n\n"                                 | tee -a "$out"
  rm -rf "$1.bin"
}

# Run Nido on all graphs
runAll() {
  # runNido "$HOME/Data/web-Stanford.mtx"
  runNido "$HOME/Data/indochina-2004.mtx"
  runNido "$HOME/Data/uk-2002.mtx"
  runNido "$HOME/Data/arabic-2005.mtx"
  runNido "$HOME/Data/uk-2005.mtx"
  runNido "$HOME/Data/webbase-2001.mtx"
  runNido "$HOME/Data/it-2004.mtx"
  runNido "$HOME/Data/sk-2005.mtx"
  runNido "$HOME/Data/com-LiveJournal.mtx"
  runNido "$HOME/Data/com-Orkut.mtx"
  runNido "$HOME/Data/asia_osm.mtx"
  runNido "$HOME/Data/europe_osm.mtx"
  runNido "$HOME/Data/kmer_A2a.mtx"
  runNido "$HOME/Data/kmer_V1r.mtx"
}

# Run GALP 5 times for each graph
for i in {1..5}; do
  runAll
done

# Signal completion
curl -X POST "https://maker.ifttt.com/trigger/puzzlef/with/key/${IFTTT_KEY}?value1=$src$1"
