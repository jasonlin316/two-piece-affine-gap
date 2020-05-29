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
//Programmable Factors
int match = 20;
int penalty = -1;
int alpha = 22;
int beta = 2;
//Scoring Functions
int similarity(char a,char b);
int score(vector<vector<int> >& dp,int row,int col,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&);
void E_func(vector<vector<int> >& dp,int row,int col);
void F_func(vector<vector<int> >& dp,int row,int col);
void calculation(vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&);
void traceback(vector<vector<int> > dp,vector<vector<int> >,int,int);
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
    /*for(int i = 0;i < data.size();i++){
        smith_waterman(data[i][0],data[i][1]);
    }*/
    
    s = "x" + data[0][0];
    t = "x" + data[0][1];
    int row = s.length();
    int col = t.length();
    vector<vector<int> > dp(row,vector<int>(col));
    vector<vector<int> > E_matrix(dp.size(),vector<int>(dp[0].size()));
    vector<vector<int> > F_matrix(dp.size(),vector<int>(dp[0].size()));
    vector<vector<int> > d_matrix(dp.size(),vector<int>(dp[0].size()));
    //high_resolution_clock::time_point t1 = high_resolution_clock::now();
    calculation(dp,E_matrix,F_matrix,d_matrix);
    //high_resolution_clock::time_point t2 = high_resolution_clock::now();
    //printMatrix(d_matrix,"../dat/direction.csv");
    printMatrix(E_matrix,"../dat/I.csv");
    printMatrix(F_matrix,"../dat/D.csv");
    printMatrix(dp,"../dat/H.csv");
    cout<<"--------Finish----------"<<endl;
    //printMatrix(E_matrix);
    traceback(dp,d_matrix,x,y);
    reverse(l1.begin(),l1.end());
    reverse(l2.begin(),l2.end());
    
    cout<<l1<<endl;
    cout<<l2<<endl;
    //<double> time_span = duration_cast<duration<double> >(t2 - t1);
    cout<<"score: "<<biggest<<endl;
    //std::cout << "Tooked " << (time_span.count()*1000000)  << " us.";
    std::cout << std::endl;
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


int score(vector<vector<int> >& dp,int row,int col,vector<vector<int> >& E,vector<vector<int> >& F,vector<vector<int> >& D){
    //return the highest socre of the four
    int topleft = dp[row-1][col-1];
    int a = topleft + similarity(s[row],t[col]);
    int tmp1,tmp2,d1,d2,tmp_max;
    E_func(dp,E,row,col);
    F_func(dp,F,row,col);
    if(a >= E[row][col]){ tmp1 = a; d1 = 1;}
    else{ tmp1 = E[row][col]; d1 = 2;}
    if(F[row][col] >= 0){ tmp2 = F[row][col]; d2 = 3;}
    else{ tmp2 = 0; d2 = 0;}
    tmp_max = max(tmp1,tmp2);
    if(tmp_max > biggest){ y = row ; x = col; biggest = tmp_max;}//record the coordinate of the biggest value
    if(tmp1 >= tmp2){ D[row][col] = d1; return tmp1;}
    else{ D[row][col] = d2; return tmp2;}
    //return max((max(a,E[row][col])),(max(F[row][col],0)));
}

void calculation(vector<vector<int> >& dp,vector<vector<int> >& E,vector<vector<int> >& F,vector<vector<int> >& D) 
{ 
    
    int ROW = dp.size();
    int COL = dp[0].size();
    for (int x = 0; x < ROW; x++)
    {
        E[x][0] = -9999;
        F[x][0] = -9999;
    }
    for (int y = 0; y < COL; y++)
    {
        E[0][y] = -9999;
        F[0][y] = -9999;
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
            dp[row][col] = score(dp,row,col,E,F,D);
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


