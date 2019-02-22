# gabac-tools

This repository contains some benchmarking and testing tools for the gabac entropy coder available at https://github.com/mitogen.

## Configurations

There are several configurations for gabac as json files. 
They are sorted by their word size into different directories and each configuration enables exactly one gabac 
feature while disabling all other features. The configuration each json is based on is the following:

```
{
    "word_size": "1",
    "sequence_transformation_id": "0",
    "sequence_transformation_parameter": "0",
    "transformed_sequences":
    [
        {
            "lut_transformation_enabled": "0",
            "lut_transformation_bits": "0",
            "lut_transformation_parameter": "0",
            "lut_transformation_order": "0",
            "diff_coding_enabled": "0",
            "binarization_id": "0",
            "binarization_parameters":
            [
                "8"
            ],
            "context_selection_id": "0"
        }
    ]
}
```
Note that this configuration is literally doing nothing: there is no sequence transformation, no lut transform, no diff transform, 
CABAC in bypass mode and BI binarization with wordsize equal to its parameter (8 bits = 1 byte) will just write out the values as they are.
Therefore this configuration is called "none". Starting from here, the following configurations have been created:

***equality***: equality coding enabled  
***match***: match coding enabled  
***rle***: run length encoding enabled  
***EG***: exponential golomb binarization enabled  
***TU****: truncated unary binarization enabled  
***ord0***: CABAC context order 0 enabled  
***ord1***: CABAC context order 1 enabled  
***ord2***: CABAC context order 2 enabled  
***diff***: Diff coding enabled  
***lut0***: look up table order 0 enabled  
***lut1***: look up table order 1 enabled  
  
*disabled by default by renaming the corresponding file as TU will often freeze gabac if the input stream is not valid for it.
Only rename if you know your input is TU compatible.

There are no configurations for these gabac features:

TEG binarization: it's just a mix between TU and EG and therefore not necessary to test
Signed binarizations: They are also just a variant of the binarizations 

All configurations are not intended to achieve a good compression ratio or to be used in real applications. 
They are just for performance tests.

## Scripts

### benchmark.sh 
Launches a performance benchmark. It will encode all files provided as arguments using all
json configurations, decode the file, measure the time and memory used and output a file "total.txt" containing the cumulated results.
The simulations will be run multiple times and the average values will be used in the results file. You can specify that number
of iterations with the "numruns" variable at the top of the script. Be aware that you also need to adapt the path to a gabacify executable in
encode.sh in order to have this working. Example:

```
./benchmark.sh testfile1 testfile2
```

Example output (stream/operation, time in seconds, max. memory in kb):
```
testfile1.1diff.decode	1.07	4517
testfile1.1diff.encode	2.60	4535
testfile1.1EG.decode	3.25	4488
testfile1.1EG.encode	1.03	4519
testfile1.1equality.decode	5.36	4532
testfile1.1equality.encode	2.31	4496
```
