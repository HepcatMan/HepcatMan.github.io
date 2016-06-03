if [ $# = 0 ]; then
	echo "commit blog and source"
	sh ./blog.sh; sh ./backup.sh

elif [ $1 = "blog" ]; then
	echo "commit blog"
	sh ./blog.sh

elif [ $1 = "source" ]; then
	echo "commit source"
	sh ./backup.sh
fi

