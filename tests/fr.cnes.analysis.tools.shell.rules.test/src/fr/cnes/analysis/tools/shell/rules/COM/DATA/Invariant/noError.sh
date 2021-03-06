#!/bin/bash
echo "------------------------------------------"
echo "COM.DATA.INVARIANT"
echo "Fichier OK de TU"
echo "------------------------------------------"

# Exemple avec un nombre
declare -r x=2
declare -r z=3
declare -r y=$(($z+$x))
echo "Exemple avec un nombre : "${y}

# Exemple avec une chaine de caractère
readonly chaine="Exemple "
readonly ok="ok"
chaine_test="$chaine $ok"
echo "Exemple avec une chaîne de caractère : "${chaine_test}
chaine_test="Nouvelle valeur"
echo "------------------------------------------"

function fonction ()
{
  local -r position=5
  echo "Variable locale 'position' dans la fonction : $position"
}


fonction2 ()
{
  typeset -r pos=3
}
