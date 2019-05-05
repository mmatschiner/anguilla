# m_matschiner Sun Nov 11 22:53:35 CET 2018

# Load modules.
module load beast2/2.5.0
module load beagle-lib/2.1.2

# Make the result directory.
mkdir -p ../res/beast

# Copy the xml file.
if [ ! -f ../res/beast/eel_assemblies.xml ]
then
    cp ../data/xml/eel_assemblies.xml ../res/beast
fi

# Move to the result directory and run the beast analysis.
cd ../res/beast
beast -seed ${RANDOM} eel_assemblies.xml
treeannotator -burnin 10 -heights mean eel_assemblies.trees eel_assemblies.tre
cd -