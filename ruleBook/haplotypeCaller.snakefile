rule HAPCALLER:
	input: 	
		bam="{subject}/{sample}/{sample}.bwa.final.bam",
		bai="{subject}/{sample}/{sample}.bwa.final.bam.bai",
		ref=config["reference"],
		dbsnp=config["dbsnp"],
		interval=lambda wildcards: config['target_intervals'][config['sample_captures'][wildcards.sample]],
	output:
		vcf="{subject}/{sample}/calls/{sample}.hapcaller.raw.vcf"
	version: config["GATK"]
	params:
		rulename = "HC",
		batch    = config[config['host']]["job_gatk"]
	shell: """
	#######################
	module load GATK/{version}
	gawk '{{print $1 "\t" $2-1 "\t" $3}}' {input.interval} > ${{LOCAL}}/target_intervals.bed
	java -Xmx${{MEM}}g -Djava.io.tmpdir=${{LOCAL}} -jar $GATK_JAR -T HaplotypeCaller -R {input.ref} {input.bam} -L ${{LOCAL}}/target_intervals.bed -o {output.vcf} --dbsnp {input.dbsnp} -mbq 20 -mmq 30
	#######################
	"""