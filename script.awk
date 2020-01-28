{
#Docker file
print "\nRUN useradd "$1"&&\\">>"Dockerfile"
print "\techo "$2" | passwd --stdin "$1"&&\\">>"Dockerfile"
}
