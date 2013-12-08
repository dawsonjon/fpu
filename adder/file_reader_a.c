void file_reader_a(){
	unsigned temp;
	while(1){
		temp = file_read("stim_a");
		output_z(temp);
	}
}
