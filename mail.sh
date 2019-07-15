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
read -p "set your user name :" name
read -sp "set your user password :" pass
cd $directory
grep -l server_name * | xargs -I {} sed -i {} -e  s/server_name/$domain/g
grep -l dkim_selector * | xargs -I {} sed -i {} -e  s/dkim_selector/$selector/g

	echo -e "\nRUN useradd $name;\\">>Dockerfile
	echo "echo $pass | passwd --stdin $name">>Dockerfile
	echo ""
	while :
		do
		read -p "do you add other user ? (y/n):" u_add
		if [ ${u_add,,} = "y" ]; then
		read -p "set your user name :" name
		read -sp "set your user password :" pass
		echo -e "\nRUN useradd $name;\\">>Dockerfile
		echo "echo $pass | passwd --stdin $name">>Dockerfile
		echo ""
		fi

		if [ ${u_add,,} = "n" ]; then
				break
		fi
		done

read -p "do you want to up this container ? (y/n):" yn
if [ ${yn,,} = "y" ]; then
	docker-compose up --build -d
fi
chmod 777 /home/docker_home
