std::ofstream file(std::string(std::getenv("HOME")) + "/.teleop/data.txt", std::ios::out);
file << 123;
file.close();

