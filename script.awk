{
#Docker file
print "\nRUN useradd "$1"&&\\">>"Dockerfile"
print "\techo "$2" | passwd --stdin "$1>>"Dockerfile"
print "\nchown -R "$1":"$1" /home/"$1>>"run.sh"
}
