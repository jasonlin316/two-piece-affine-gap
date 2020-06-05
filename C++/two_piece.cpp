using namespace std;

#include <iostream>
#include <cmath>
#include <vector>
#include <string>
#include <algorithm>
#include <ctime>
#include <ratio>
#include <chrono>
#include <fstream>
#include <sstream> 
//Programmable Factors
int match = 20;
int penalty = -1;
int alpha = 14;
int beta = 4;
int alpha_hat = 22;
int beta_hat  = 2;
//Scoring Functions
int similarity(char a,char b);
int score(vector<vector<int> >& dp,int row,int col,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&);
void E_func(vector<vector<int> >& dp,int row,int col);
void F_func(vector<vector<int> >& dp,int row,int col);
void E_hat_func(vector<vector<int> >& dp,int row,int col);
void F_hat_func(vector<vector<int> >& dp,int row,int col);
void calculation(vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&);
void traceback(vector<vector<int> > dp,vector<vector<int> >,int,int);
void convertToBinary(string s);
//Some Comparison Functions
int min(int a, int b) { return (a < b)? a: b; }  
int min(int a, int b, int c) { return min(min(a, b), c);} 
int max(int a, int b) { return (a > b)? a: b; } 
//Global Variables
string s,t;
string l1,l2;
int x,y,biggest=0;



void printMatrix(vector<vector<int> >& dp, string file_location) 
{   
     std::ofstream myfile;
     //myfile.open ("../dat/direction.csv");
     myfile.open (file_location);
     myfile<<"";
    int ROW = dp.size();
    int COL = dp[0].size();
    for (int i=1; i< ROW; i++) 
    { 
        for (int j=1; j<COL; j++)myfile << dp[i][j] << "," ;
        myfile << "\n"; 
    } 
    myfile.close();
} 

int main(){
    using namespace std::chrono; 
    /* int w,l;
    cout<<"Input sequence Query:";
    cin >> t;
    cout<<"Input sequence Reference:";
    cin >> s;
    if(s.size()==0 || t.size()==0) return 0; */
    ofstream myfile;
    myfile.open ("../dat/BinaryInput.dat",ios::out | ios::trunc);
    myfile.close();
    ofstream myfile2;
    myfile2.open ("../dat/data_size.dat",ios::out | ios::trunc);
    myfile2.close();
    ofstream myfile3;
    myfile3.open ("../dat/start_pt.dat",ios::out | ios::trunc);
    myfile3.close();

    ifstream file("../dat/input.dat");
    string str,token;
    string delimiter = "_";
    size_t pos = 0;
    vector<vector<string> > data(1,vector<string>(2));
    int i = 0;
    while (std::getline(file, str))
    { 
        std::transform(str.begin(), str.end(), str.begin(), ::tolower);
        data[i/2][i%2] = str;
        if(i%2)data.push_back(vector<string>(2));
        i+=1;
    }
    data.pop_back();
    for(int i = 0;i < data.size();i++){
        //smith_waterman(data[i][0],data[i][1]);
        biggest = 0;
        s = "x" + data[i][0];
        t = "x" + data[i][1];
        string rev_s = s;
        string rev_t = t;
        reverse(rev_s.begin(), rev_s.end());
        reverse(rev_t.begin(), rev_t.end());
        convertToBinary(rev_s);
        convertToBinary(rev_t);
        int row = s.length();
        int col = t.length();
        vector<vector<int> > dp(row,vector<int>(col));
        vector<vector<int> > E_matrix(dp.size(),vector<int>(dp[0].size()));
        vector<vector<int> > F_matrix(dp.size(),vector<int>(dp[0].size()));
        vector<vector<int> > E_hat_matrix(dp.size(),vector<int>(dp[0].size()));
        vector<vector<int> > F_hat_matrix(dp.size(),vector<int>(dp[0].size()));
        vector<vector<int> > d_matrix(dp.size(),vector<int>(dp[0].size()));
        calculation(dp,E_matrix,F_matrix,d_matrix,E_hat_matrix,F_hat_matrix);
        ofstream myfile3;
        myfile3.open ("../dat/start_pt.dat",ios::out | ios::app);
        myfile3 << x << endl;
        myfile3 << y << endl;
        myfile3.close();
        printMatrix(E_matrix,"../dat/E.csv");
        printMatrix(F_matrix,"../dat/F.csv");
        printMatrix(E_hat_matrix,"../dat/E_hat.csv");
        printMatrix(F_hat_matrix,"../dat/F_hat.csv");
        printMatrix(d_matrix,"../dat/encode.csv");
        printMatrix(dp,"../dat/H.csv");
        cout<<"--------Finish----------"<<endl;
        cout<<"score: "<<biggest<<endl;
        cout<<"x:"<<x<<"; y:"<< y<<endl;
    }
    
    //std::cout << "Tooked " << (time_span.count()*1000000)  << " us.";
    //std::cout << std::endl;
}

int similarity(char a,char b){
    if(a==b) return match;
    else return penalty;
}

void E_func(vector<vector<int> >& dp,vector<vector<int> >& E,int row,int col){
    int a = dp[row][col-1] - alpha;
    //if(a<0) a = 0;
    int b = E[row][col-1] - beta;
    E[row][col] = max(a,b);
}

void F_func(vector<vector<int> >& dp,vector<vector<int> >& F,int row,int col){
    int a = dp[row-1][col] - alpha;
    //if(a<0) a = 0;
    int b = F[row-1][col] - beta;
    F[row][col] = max(a,b);
}

void E_hat_func(vector<vector<int> >& dp,vector<vector<int> >& E_hat,int row,int col){
    int a = dp[row][col-1] - alpha_hat;
    int b = E_hat[row][col-1] - beta_hat;
    E_hat[row][col] = max(a,b);
}

void F_hat_func(vector<vector<int> >& dp,vector<vector<int> >& F_hat,int row,int col){
    int a = dp[row-1][col] - alpha_hat;
    int b = F_hat[row-1][col] - beta_hat;
    F_hat[row][col] = max(a,b);
}



int score(vector<vector<int> >& dp,int row,int col,vector<vector<int> >& E,vector<vector<int> >& F,vector<vector<int> >& D,vector<vector<int> >& E_hat, vector<vector<int> >& F_hat){
    //return the highest socre of the four
    int topleft = dp[row-1][col-1];
    int a = topleft + similarity(s[row],t[col]);
    int tmp1,tmp2,d1,d2,tmp_max;
    int source;
    int Ho,Ie,De,Ho_,Ie_,De_;
    E_func(dp,E,row,col);
    E_hat_func(dp,E_hat,row,col);
    F_func(dp,F,row,col);
    F_hat_func(dp,F_hat,row,col);

    /*if(a >= E[row][col]){ tmp1 = a; d1 = 1;}
    else{ tmp1 = E[row][col]; d1 = 2;}
    if(F[row][col] >= 0){ tmp2 = F[row][col]; d2 = 3;}
    else{ tmp2 = 0; d2 = 0;}
    tmp_max = max(tmp1,tmp2);*/

    tmp_max = max(a,max( max(F[row][col],F_hat[row][col]),max(E[row][col],E_hat[row][col]) ));
    if(tmp_max == a) source = 16;
    else if (tmp_max == F[row][col]) source = 7;
    else if (tmp_max == F_hat[row][col]) source = 15;
    else if (tmp_max == E[row][col]) source = 3;
    else if (tmp_max == E_hat[row][col]) source = 11;
    else source = -1; //error
    if(source == 16)
    {
        Ho  = a - alpha;
        Ie  = F[row][col] - beta;
        De  = E[row][col] - beta;
        Ho_ = a - alpha_hat;
        Ie_ = F_hat[row][col] - beta_hat;
        De_ = E_hat[row][col] - beta_hat;

        if( Ie > Ho && Ho >= De) source += 8;
        else if (Ie >= De && De > Ho) source += 12;
        else if (De > Ho && Ho >= Ie) source += 4;
        else if (De > Ie && Ie > Ho)  source += 12;

        if (Ie_ > Ho_ && Ho_ >= De_) source += 2;
        else if (Ie_ >= De_ && De_ > Ho_) source += 3;
        else if (De_ > Ho_ && Ho_ >= Ie_) source += 1;
        else if (De_ > Ie_ && Ie_ > Ho_) source += 3;

    }

    D[row][col] = source;



    if(tmp_max > biggest){ y = row ; x = col; biggest = tmp_max;}//record the coordinate of the biggest value
    return tmp_max;
    //return max((max(a,E[row][col])),(max(F[row][col],0)));
}

void calculation(vector<vector<int> >& dp,vector<vector<int> >& E,vector<vector<int> >& F,vector<vector<int> >& D,vector<vector<int> >& E_hat,vector<vector<int> >& F_hat) 
{ 
    
    int ROW = dp.size();
    int COL = dp[0].size();
    for (int x = 0; x < ROW; x++)
    {
        E[x][0] = -9999;
        F[x][0] = -9999;
        E_hat[x][0] = -9999;
        F_hat[x][0] = -9999;
    }
    for (int y = 0; y < COL; y++)
    {
        E[0][y] = -9999;
        F[0][y] = -9999;
        E_hat[0][y] = -9999;
        F_hat[0][y] = -9999;
    }
	for (int line = 1; line <= (ROW + COL -1); line++) 
	{ 
		int start_row = max(0, line-COL); 
		int count = min(line, (ROW-start_row), COL); 

		for (int j=0; j<count; j++)
        {
            int row = (start_row+j);
            int col = (min(COL, line)-j-1);
            if(row == 0 || col == 0) continue;
            dp[row][col] = score(dp,row,col,E,F,D,E_hat,F_hat);
        }
	} 
} 

void traceback(vector<vector<int> > dp,vector<vector<int> > d_matrix,int x,int y)
{
    //1:topleft,2:left,3:up,0:stop
    if(dp[y][x] == 0) return;
    else if(d_matrix[y][x]==1)
    {
        l1 += t[x];
        l2 += s[y];
        traceback(dp,d_matrix,x-1,y-1);
    }
    else if (d_matrix[y][x]==2)
    {
        l1 += t[x];
        l2 += "-" ;
        traceback(dp,d_matrix,x-1,y);
    }
    else if (d_matrix[y][x]==3)
    {
        l1 += "-";
        l2 += s[y];
        traceback(dp,d_matrix,x,y-1);
    }
}

void convertToBinary(string s)
{
    int s_size = s.size();
    string binaryS = "";
    for(int i = 0; i<s_size ; i++)
    {   
        switch(s[i])
        {
            case 'a':
                binaryS += "00_";
            break;
            case 't':
                binaryS += "01_";
            break;
            case 'c':
                binaryS += "10_";
            break;
            case 'g':
                binaryS += "11_";
            break;
            default:
                binaryS = binaryS;
        }
    }
    //binaryS += "010";
    binaryS.pop_back();

    ofstream myfile;
    myfile.open ("../dat/BinaryInput.dat",ios::out | ios::app);
    myfile << binaryS << endl;
    myfile.close();

    stringstream ss; 
    ss << hex << (s_size-1 ); 
    string res = ss.str(); 
    int add_zero_amount = 3;
    add_zero_amount -= res.length();
    std::string dest = std::string( add_zero_amount, '0').append(res);

    ofstream myfile2;
    myfile2.open ("../dat/data_size.dat",ios::out | ios::app);
    myfile2 << dest << endl;
    myfile2.close();

}



