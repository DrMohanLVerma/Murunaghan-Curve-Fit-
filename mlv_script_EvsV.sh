#!/bin/bash

#======================================================#
# Script: Enegy vs Volume data file generation         #
# Author: Mohan L Verma, Computational Nanomaterial    #  
# Research lab, Department of Applied Physics,         #
# Shri Shanakaracharya Technical Campus-Junwani        # 
# Bhilai(Chhattisgarh)  INDIA                          #
# Feb 29   ver: 1.0    year: 2025                      #
# it is assumed that siesta.exe binary file is linked  #
# bin directory after parallel compilation of siesta   #
#------------------------------------------------------#
# run this script using cammand                        #
#  sh mlv_script_EvsV.sh                               #
# this will creat 16 folders with complete siesta run  #
# and give xmgrace plot to find optimum EvsV.          #
#======================================================#
# give feedback in                                     #
#                                                      # 
#                  drmohanlv@gmail.com                 #
#===================================================== #
> EvsV.dat  
mkdir EvsV_var
cd EvsV_var

mkdir cont   # read the comment at the end of this script.

for i in `seq -w 0.85 0.025 1.4 `  
do


cp -r cont $i
cd $i
cp ../../*.psf .
cp /home/drmohanlv/siesta-5.2.2/bin/siesta .  # give the path of siesta binary


cat > AlN.fdf <<EOF

SystemName       AlN
SystemLabel      AlN

NumberOfAtoms    4

NumberOfSpecies  2
%block ChemicalSpeciesLabel
    1   13  Al
    2    7  N
%endblock ChemicalSpeciesLabel

LatticeConstant $i Ang
%block LatticeParameters
  3.128600  3.128600  5.017000  90.000000  90.000000  120.000000
%endblock LatticeParameters

AtomicCoordinatesFormat Fractional
%block AtomicCoordinatesAndAtomicSpecies
     0.666700000     0.333300000     0.499300000    1
     0.333300000     0.666700000     0.999300000    1
     0.666700000     0.333300000     0.880700000    2
     0.333300000     0.666700000     0.380700000    2
%endblock AtomicCoordinatesAndAtomicSpecies

 # K-points

%block kgrid_Monkhorst_Pack
6   0   0   0.0
0   6   0   0.0
0   0   6   0.0
%endblock kgrid_Monkhorst_Pack



#%blockSuperCell
# 1   0   0
# 1   1   0
# 0   0   9
#%endblockSuperCell

 
#%block GeometryConstraints
#position from  1 to  180
#%endblock GeometryConstraints

PAO.BasisSize     DZP
PAO.EnergyShift   0.03 eV
MD.TypeOfRun      CG
MaxSCFIterations  300
SCF.MustConverge   false
MD.NumCGsteps     000
MD.MaxForceTol    0.005  eV/Ang
MeshCutoff       250 Ry
DM.MixingWeight   0.02
DM.NumberPulay   3
WriteCoorXmol   .true.
WriteMullikenPop    1
XC.functional       LDA
XC.authors          PZ
SolutionMethod  diagon
ElectronicTemperature  50 meV
SaveRho        .true.
 
#UseSaveData     true
#DM.UseSaveDM    true
#MD.UseSaveXV    true
#MD.UseSaveCG    true





EOF

mpirun --oversubscribe -np 6 ./siesta *.fdf | tee result.out

etot=$(grep 'Total =' result.out | tail -1 | awk -F '=' '{print $2}' | xargs)
Vol=$(grep 'Cell volume =' result.out | tail -1 | awk -F '=' '{print $2}' | sed 's/Ang\*\*3//g' | xargs)

echo "$Vol   $etot" >> ../EvsV.dat



cd ..
rm -rf cont 
mkdir cont

cp   ./$i/*.DM  cont  # copy these files for continuation of the next step.


 
done
cp EvsV.dat ../

cd ..
xmgrace EvsV.dat &
rm -r -v EvsV_var


