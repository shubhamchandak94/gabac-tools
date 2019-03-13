


#include <map>
#include <bits/ios_base.h>
#include <fstream>
#include <iostream>

void getFileSizes(const std::string& file, std::map<std::string, uint64_t> *res){
    std::ifstream inputFile(file, std::ios_base::binary);
    while (inputFile.peek() != EOF) {
        uint64_t size = 0;
        inputFile.read(reinterpret_cast<char *>(&size), sizeof(uint64_t));
        std::string filename(size, ' ');
        inputFile.read(const_cast<char *>(filename.data()), size);

        inputFile.read(reinterpret_cast<char *>(&size), sizeof(uint64_t));
        inputFile.seekg(size, std::ios_base::cur);

        (*res)[filename] = size;
    }

}

void printAll(const std::map<std::string, uint64_t>& res){
    for (const auto& p : res) {
        std::cout << p.first << ", " << p.second << " bytes" << std::endl;
    }
}

void printStatistics(const std::map<std::string, uint64_t>& res){
    uint64_t idSize = 0;
    uint64_t readSize = 0;
    uint64_t qualitySize = 0;
    uint64_t otherSize = 0;
    uint64_t streamCounter = 0;
    uint64_t accessUnit = 0;
    for (const auto& p : res) {
        ++streamCounter;
        if (p.first.substr(0, 2) == "id") {
            idSize += p.second;
            continue;
        }
        if (p.first.substr(0, 7) == "quality") {
            qualitySize += p.second;
            uint64_t pos = p.first.find_last_of('.') + 1;
            std::string accessUnitString = p.first.substr(pos, p.first.length() - pos);
            uint64_t unit = atoi(accessUnitString.c_str());
            if (unit > accessUnit) {
                accessUnit = unit;
            }
            continue;
        }
        if (p.first.substr(0, 10) == "ref_subseq" ||
            p.first.substr(0, 6) == "subseq") {
            readSize += p.second;
            continue;
        }
        otherSize += p.second;
    }

    std::cout
            << "Containing "
            << streamCounter
            << " chunks in "
            << accessUnit + 1
            << " access units, total size "
            << qualitySize + otherSize + readSize + idSize
            << std::endl;
    std::cout << "IDs:       " << idSize << " bytes" << std::endl;
    std::cout << "Reads:     " << readSize << " bytes" << std::endl;
    std::cout << "Qualities: " << qualitySize << " bytes" << std::endl;
    std::cout << "Others:    " << otherSize << " bytes" << std::endl;
}

int main(int argc, char *argv[]){
    if (argc != 3) {
        std::cerr << "You must specify exactly 2 arguments. Aborting." << std::endl;
        return 1;
    }
    std::map<std::string, uint64_t> fileSizes;
    getFileSizes(argv[2], &fileSizes);
    std::string task(argv[1]);
    if (task == "details") {
        printAll(fileSizes);
    } else if (task == "overview") {
        printStatistics(fileSizes);
    } else {
        std::cerr << "Invalid task. Aborting." << std::endl;
        return 1;
    }
    return 0;
}