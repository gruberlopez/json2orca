#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <json_file>"
  exit 1
fi

json_file="$1"

if [ ! -f "$json_file" ]; then
  echo "File $json_file not found!"
  exit 1
fi

index=1




xyz_ang=

xyz_to_angstroms () {
  xyz_ang=''  
  for coord in $(echo "$1" | tr ',' ' '); do    
    coord=$(python3 -c "print(f'{$coord:1.7f}')")
    coord_ang=$(echo "$coord * 0.529177" | bc)
    coord_ang=$(python3 -c "print(f'{$coord_ang:1.7f}')")        
    xyz_ang+=$coord_ang'   '
  done    
}


get_header () {
  versionStr=$(echo $2 | jq -r ".program")
  numberVersion=$(echo "$versionStr" | grep -oP '\d+(\.\d+)+')
  sed -i "s/@@version@@/$numberVersion/g" "$1"
}

get_xyz () {
  geometry=$(echo "$2" | jq ".xyz")
  geometry_length=$(echo "$2" | jq ".xyz | length")

  xyz=""
  for i in $(seq 0 $((geometry_length - 1))); do
      atom_type=$(echo "$geometry" | jq -r ".[$i][0]")
      
      coordinates=$(echo "$geometry" | jq -r ".[$i][1] | @csv")

      xyz_to_angstroms "$coordinates"
      line1="$atom_type $xyz_ang"
      # Concatenar línea con salto de línea
      xyz+="$line1"$'\n'
  done

  # Reemplazar la variable @@xyz@@ en el archivo
  echo "$xyz" > tmp.txt
  sed -i "/@@xyz@@/r tmp.txt" "$1"
  sed -i "/@@xyz@@/d" "$1"
  rm tmp.txt
}


get_energy () {
  total_energy=$(echo $2 | jq -r ".energy")
  energy_ev=$(echo "$total_energy * 27.2114079527" | bc)
  line=$(echo "$total_energy Eh    $energy_ev eV")
  sed -i "s/@@scf_energy@@/$line/g" "$1"
}

get_multiplicity () {
  multiplicity=$(echo $2 | jq -r ".multiplicity")
  sed -i "s/@@multiplicity@@/$multiplicity/g" "$1"
}

get_charge () {
  charge=$(echo $2 | jq -r ".charge")
   sed  -i "s/@@charge@@/$charge/g" "$1"
}

get_method () {
  method=$(echo $2 | jq -r ".method")
  sed  -i "s/@@method@@/$method/g" "$1"
}

get_basis () {
  basis=$(echo $2 | jq -r ".basis_set")
  sed  -i "s/@@basis@@/$basis/g" "$1"
}

get_solvation_inp() {
  solvation_inp=$(echo $2 | jq -r ".solvation")
  solvent_inp=$(echo $2 | jq -r ".solvent")
  sed  -i "s/@@solvation@@/$solvation_inp/g" "$1"
  sed  -i "s/@@solvent@@/$solvent_inp/g" "$1"
    }

get_solvent() {
   solvent=$(echo "$2" | jq -r ".solvent")
   solvation=$(echo "$2" | jq -r ".solvation")
   solvation="${solvation^^}"
   info=${cpcm[${solvent^^}]}
   clean_info=$(echo "$info" | sed 's|//| |g')
   IFS=" " read -r epsilon refract <<< "$clean_info"

   if [[ "$solvation" == "COSMO" ]]; then
      solvationFinal="--------------------\n"
      solvationFinal+="COSMO INITIALIZATION\n"
      solvationFinal+="--------------------\n\n"
      solvationFinal+="Epsilon                                      ...  $epsilon \n"
      solvationFinal+="Refractive Index                             ...  $refract  \n"
      solvationFinal+="--------------\n"

      sed -i "s/@@solvation@@/$solvationFinal/g" "$1"

    elif [[ "$solvation" == "CPCM" ]]; then

      solvationFinal="------------------------------------------------------------------------------\n"
      solvationFinal+="CPCM SOLVATION MODEL\n"
      solvationFinal+="------------------------------------------------------------------------------\n\n"
      solvationFinal+="CPCM parameters:\n"
      solvationFinal+="Epsilon                                      ...  $epsilon \n"
      solvationFinal+="Refrac                                       ...  $refract  \n\n"
      solvationFinal+="Overall time for CPCM initialization         ...          0.0s\n"

      sed -i "s/@@solvation@@/$solvationFinal/g" "$1"

   fi
}

get_mongoDB() {
  mongodb_id=$(echo "$2" | jq -r ".mongodb_id")
  sed  -i "s/@@mongodb@@/$mongodb_id/g" "$1"
}

declare -A cpcm

set_ArrayCPCM() {
    cpcm["WATER"]="80.4//1.33"
    cpcm["ACETONITRILE"]="36.6//1.344"
    cpcm["ACETONE"]="20.7//1.359"
    cpcm["AMMONIA"]="22.4//1.33"
    cpcm["ETHANOL"]="24.3//1.361"
    cpcm["METHANOL"]="32.63//1.329"
    cpcm["CH2CL2"]="9.08//1.424"
    cpcm["CCL4"]="2.24//1.466"
    cpcm["DMF"]="38.3//1.430"
    cpcm["DMSO"]="47.2//1.479"
    cpcm["PYRIDINE"]="12.5//1.510"
    cpcm["THF"]="7.25//1.407"
    cpcm["CHLOROFORM"]="4.9//1.45"
    cpcm["HEXANE"]="1.89//1.375"
    cpcm["TOLUENE"]="2.4//1.497"
}

set_ArrayCPCM 

get_input() {
  get_method "$1" "$2"
  get_basis "$1" "$2"
  get_solvation_inp "$1" "$2"
  get_xyz "$1" "$2"
  get_charge "$1" "$2"
  get_multiplicity "$1" "$2"
}

total_compounds=$(jq 'keys | length' "$json_file")

while [ $index -le "$total_compounds" ]; do
    calc_json=$(jq -r ".\"$((index))\"" "$json_file")    
    crn_id=$(echo $calc_json | jq -r ".crn_id")    
    
    mkdir -p "./results/$index/"
    input="./results/$index/$crn_id.in"
    output="./results/$index/$crn_id.out"

    cp skeleton.in "$input"
    cp skeleton.out "$output"
    

    get_header "$output" "$calc_json"
    get_xyz "$output" "$calc_json"
    get_energy "$output" "$calc_json"
    get_charge "$output"  "$calc_json"
    get_multiplicity "$output"  "$calc_json"
    get_method "$output"  "$calc_json"
    get_basis "$output" "$calc_json"
    get_solvent "$output"  "$calc_json"
    
    get_input "$input"  "$calc_json"
    get_mongoDB "$input"  "$calc_json"
    index=$((index + 1))
done
