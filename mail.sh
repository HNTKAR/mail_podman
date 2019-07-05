echo ""
echo `pwd`
ls
echo ""
while :
	do
	read -p "do you copy directory ? (y/n):" yn

	if [ ${yn,,} = "y" ]; then
		echo "cp original_directory copy_directory"
		read -p "original_directory:" o_dir
		echo o_dir=$o_dir
		read -p "copy_directory:" c_dir
		echo c_dir=$c_dir
		rm -rf $c_dir
		cp -r $o_dir $c_dir
		directory=$c_dir
		break
	fi

	if [ ${yn,,} = "n" ]; then
		read -p "set your directory name :" directory
		break
	fi

	done

read -p "set your server domain :" domain
read -p "set your dkim selector :" selector
read -p "set your user name :" names
read -sp "set your user password :" passes
cd $directory
name_array=($names)
pass_array=($passes)
grep -l server_name * | xargs -I {} sed -i {} -e  s/server_name/$domain/g
grep -l dkim_selector * | xargs -I {} sed -i {} -e  s/dkim_selector/$selector/g

for i in `seq ${#name_array[*]}`
	do
	echo -e "\nRUN useradd ${name_array[$((i-1))]};\\">>Dockerfile
	echo "echo ${pass_array[$((i-1))]} | passwd --stdin ${name_array[((i-1))]}">>Dockerfile
done
echo ""

read -p "do you want to up this container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	docker-compose up --build -d
fi
