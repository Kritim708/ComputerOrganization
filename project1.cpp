/*
    project1.cpp
    Author: Kritim K. Rijal and Tenzin Tsekyi
    Description: Implementation of project1 methods
*/



#ifndef __PROJECT1_CPP__
#define __PROJECT1_CPP__

#include "project1.h"
#include <vector>
#include <string>
#include <map>
#include <iostream>
#include <sstream>
#include <fstream>
#include <bitset>

using namespace std;

int main(int argc, char* argv[]) {
    if (argc < 4) // Checks that at least 3 arguments are given in command line
    {
        std::cerr << "Expected Usage:\n ./assemble infile1.asm infile2.asm ... infilek.asm staticmem_outfile.bin instructions_outfile.bin\n" << std::endl;
        exit(1);
    }

    //Prepare output files
    std::ofstream inst_outfile, static_outfile; //declare two output stream files
    static_outfile.open(argv[argc - 2], std::ios::binary);// To pen the static memory output file in binary 
    inst_outfile.open(argv[argc - 1], std::ios::binary);// To pen the inst_output file in binary 
    std::vector<std::string> instructions; //create a vector to store all the instruction line labels
    std::vector<std::string> bytes; //create a vector bytes to store static memory labels

    /**
     * Phase 1:
     * Read all instructions, clean them of comments and whitespace 
     * Determine the numbers for all static memory labels
     * (measured in bytes starting at 0)
     * Determine the line numbers of all instruction line labels
     * (measured in instructions) starting at 0
    */

    
    bool stack = false; // Indicates whether we are processing stack or instructions
    int line_number = 1; // Initialize line number

    

    //For each input file:
    for (int i = 1; i < argc - 2; i++) {
        std::ifstream infile(argv[i]); //  open the input file for reading
        if (!infile) { // if file can't be opened, need to let the user know
            std::cerr << "Error: could not open file: " << argv[i] << std::endl; //outputs error message
            exit(1);
        }

        

        //Removing comments and whitespaces
        std::string str;
        while (getline(infile, str)){ //Read a line from the file
        
            str = clean(str); // remove comments, leading and trailing whitespace
            // cout << str << endl;
            if (str == "") { //Ignore empty lines
                continue;

            //Creating labels for values with ":" at the end
            } else if (str.back() == ':'){
                labels_line[str.substr(0, str.length() - 1)] = line_number;//in labels_line unordered map, set the value as as the current str without the : at the end and set it's value as the lime number
                continue;

            //when .data comes up or .text we switch from writing to instruction to writing to stack
            } else if ((str == ".data") || (str == ".text")) {
                stack =  (!stack); //switch the boolean value for stack (when .data or .text comes)
                continue;
            
            }  else if (str == ".globl main"){//Ignoring .globl main
                continue;
            
            } else if (str.substr(0, 6) == ".align"){
                continue;
            }

            //Writing to stack or instruction file
            if (stack){ //if stack is true
                bytes.push_back(str); //push str into bytes vector
            } else { //if stack is false
                instructions.push_back(str); // push str into instructions
                
                line_number ++; //increment line number
                // cout << line_number << " " << instructions.size() << endl;
            }
        }
        infile.close();
        
    }

    
    /** Phase 2
     * Process all static memory, output to static memory file
     */
    int memory_counter = 0; //initialize variable memory_counter to help count the total memory of a data type later on

    //using for loop to go through the string stored in bytes (static memory)
    //"_END_OF_STATIC_MEMORY: memory_counter"
    for (std::string memory : bytes ){

        

        vector<string> terms = split(memory, WHITESPACE + ",()"); //make vector terms and store the split strings with delimeters as any whitespace including commas and brackets
        string label = terms[0].substr(0, terms[0].length()-1); //string label stores the first term, the label without the ":" - example like array3, barray etc.
        string type = terms[1].substr(1, terms[1].length());//string type holds the 2nd term, usually the  type without the "." at the beginning, eg: word etc.

        labels_memory[label] = memory_counter; //In labels_memory map, the label (e.g like array3) is paired with matching memory location, memory_counter). Helps to later calculate the memory address for labels

        if (type == "word"){ //if the type is word, then update the memory counter value based on the size of the terms and subtract 2 because we are excluding the the first two terms labels and type, we only need teh rest to calculate the size
            memory_counter += 4 * (terms.size()-2); //update the memory_counter size
            //using for loop to go after the terms after the label and type
            for (int i = 2; i < terms.size(); i++){
                if (labels_line.find(terms[i]) == labels_line.end()){ //if the term[i] is not found in the unordered map
                    write_binary(stoi(terms[i]), static_outfile);//then call the write_binary funtion and the first argument as by convert the term[i] string type to interger
                }else { //else
                    write_binary((labels_line[terms[i]] - 1)*4, static_outfile); //call write binary fucntion and find the value at the labels_line map with key as the term[i] and subtract that by 1 and multiply by 4 to get its offset 
                }
            }        
        } else if (type == "asciiz") {
            string string_val = terms[2];
            if (terms.size() > 3){
                for (int i = 3; i <terms.size(); i++){
                    string_val += " " + terms[i];
                }
            }

            memory_counter += 4* (string_val.size() - 2);
            for (int i = 1; i < string_val.size()-1; i++){
                write_binary(static_cast<int>(string_val[i]), static_outfile);
            }
            
        }
    }


    labels_memory["_END_OF_STATIC_MEMORY_"] = memory_counter;
    // write_binary(-90, static_outfile);





    /** Phase 3
     * Process all instructions, output to instruction memory file
     */
    line_number = 0; //variable line number to keep track of the goinng by line number in instruction

    //using for loop to loop through each instructions
    for(std::string inst : instructions) {
        std::vector<std::string> terms = split(inst, WHITESPACE+","); //split the current inst string with delimmeters as whitesapces and including comma and brackte
        std::string inst_type = terms[0]; //let variable inst_type be the first term in terms

        //R-type instructions
        if (inst_type == "add") { //if the first term is add, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode, shftamt and funccode)
            write_binary(encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 32),inst_outfile);
        }else if (inst_type == "sub") {//if the first term is sub, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode, shftamt and funccode)
            write_binary(encode_Rtype(0,registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 34),inst_outfile);
        } else if (inst_type == "jr"){//if the first term is jr, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode, shftamt and funccode)
            write_binary(encode_Rtype(0, registers[terms[1]], 0, 0, 0, 8), inst_outfile);
        } else if (inst_type == "jalr"){//if the first term is jalr, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode, shftamt and funccode)
            if (terms.size() == 3){ //if the term size is 3, eg like jalr $s0, $s1, then take the 2 terms as registers
                write_binary(encode_Rtype(0, registers[terms[1]], 0, registers[terms[2]], 0, 9), inst_outfile);
            } else { //else include $ra as the 2nd register 
                write_binary(encode_Rtype(0, registers[terms[1]], 0, registers["$ra"], 0, 9), inst_outfile);
            }
        } else if (inst_type == "mult"){//if the first term is mult, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode,registers, shftamt and funccode)
            write_binary(encode_Rtype(0, registers[terms[1]], registers[terms[2]], 0, 0, 24), inst_outfile);
        } else if (inst_type == "div"){//if the first term is div, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode, registers, shftamt and funccode)
            write_binary(encode_Rtype(0, registers[terms[1]], registers[terms[2]], 0, 0, 26), inst_outfile);
        } else if (inst_type == "mflo"){//if the first term is mflo, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode,registers,  shftamt and funccode)
            write_binary(encode_Rtype(0, 0, 0, registers[terms[1]], 0, 18), inst_outfile);
        } else if (inst_type == "mfhi"){//if the first term is mfhi, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode,registers,  shftamt and funccode)
            write_binary(encode_Rtype(0, 0, 0, registers[terms[1]], 0, 16), inst_outfile);
        } else if (inst_type == "sll"){//if the first term is sll, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode,registers,  shftamt and funccode)
            write_binary(encode_Rtype(0, 0, registers[terms[2]], registers[terms[1]], stoi(terms[3]), 0), inst_outfile);
        } else if (inst_type == "srl"){//if the first term is srl, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode,registers,  shftamt and funccode)
            write_binary(encode_Rtype(0, 0, registers[terms[2]], registers[terms[1]], stoi(terms[3]), 2), inst_outfile);
        } else if (inst_type == "slt"){//if the first term is slt, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode,registers,  shftamt and funccode)
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42), inst_outfile);  
        } else if (inst_type == "syscall"){//if the first term is syscall, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode,registers,  shftamt and funccode)
            write_binary(encode_Rtype(0, 0, 0, 26, 0, 12), inst_outfile);
        } else if (inst_type == "la"){//if the first term is la, call the write binary function, call the rtype function, pass the appropiate terms as arguments and write the appropiate opcode,registers,  shftamt and funccode)
            // write_binary(encode_Rtype(8, 0, registers[terms[1]], 0, 0, labels_memory[terms[2]]), inst_outfile);
            write_binary(encode_Itype(8, 0, registers[terms[1]], labels_memory[terms[2]]), inst_outfile);
        
        //I-type instructions
        } else if (inst_type == "addi"){//if the first term is addi, call the write binary function, call the Itype function, pass the appropiate terms as arguments and write the appropiate opcode, registers, and const value)
            write_binary(encode_Itype(8, registers[terms[2]], registers[terms[1]], twos_complement(stoi(terms[3]))), inst_outfile);
        } else if (inst_type == "beq"){//if the first term is beq, call the write binary function, call the Itype function, pass the appropiate terms as arguments and write the appropiate opcode, registers, and const value)
            write_binary(encode_Itype(4, registers[terms[1]], registers[terms[2]], twos_complement(labels_line[terms[3]]-(line_number+2))), inst_outfile);
        } else if (inst_type == "bne"){//if the first term is bne, call the write binary function, call the Itype function, pass the appropiate terms as arguments and write the appropiate opcode, registers, and const value)
            write_binary(encode_Itype(5, registers[terms[1]], registers[terms[2]], twos_complement(labels_line[terms[3]]-(line_number+2))), inst_outfile);
        } else if (inst_type == "lw"){//if the first term is lw, call the write binary function, call the Itype function, pass the appropiate terms as arguments and write the appropiate opcode, registers, and const value)
            int offset = stoi(terms[2].substr(0, terms[2].find('('))); //find the offset of term 2 before the '(' part
            string _register = terms[2].substr(terms[2].find('(')+1, terms[2].length() - terms[2].find('(')-2); //extract between '(' and ')' and store it in the string register
            write_binary(encode_Itype(35,registers[_register], registers[terms[1]], offset ), inst_outfile);     
        } else if (inst_type == "sw"){//if the first term is sw, call the write binary function, call the Itype function, pass the appropiate terms as arguments and write the appropiate opcode, registers, and const value)
            int offset = stoi(terms[2].substr(0, terms[2].find('('))); //find teh offset of term 2
            string _register = terms[2].substr(terms[2].find('(')+1, terms[2].length() - terms[2].find('(')-2);
            write_binary(encode_Itype(43, registers[_register], registers[terms[1]], offset ), inst_outfile);

        //J-type instructions
        } else if (inst_type == "j"){//if the first term is j, call the write binary function, call the Jtype function, write the appropiate opcode, and address)
            write_binary(encode_Jtype(2, twos_complement(labels_line[terms[1]]-1)), inst_outfile);
        } else if (inst_type == "jal"){//if the first term is jal, call the write binary function, call the Jtype function, write the appropiate opcode, and address)
            write_binary(encode_Jtype(3, twos_complement(labels_line[terms[1]]-1)), inst_outfile);
        }
        //Increasing line number
        line_number++;
    }
}

#endif
