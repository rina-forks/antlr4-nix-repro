#include "SemanticsParser.h"
#include "SemanticsLexer.h"

#include <iostream>
#include <string>

int main() {
  std::string line;
  while (std::getline(std::cin, line))
  {
    antlr4::ANTLRInputStream input{line};
    aslt::SemanticsLexer lexer{&input};
    antlr4::CommonTokenStream tokens{&lexer};
    aslt::SemanticsParser parser{&tokens};

    auto ctx = parser.stmt_lines();
    std::cout << "ctx: " << ctx << std::endl;
  }
}
