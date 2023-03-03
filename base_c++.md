## base C++准备内容
### 1. memory area classing
* **全局区(静态存储区):** 全局变量、静态变量(static var)、常量、os释放
* **栈区:** 就记住局部即可
> 3 静态变量只初始化一次
> 5 静态函数，只在声明中可见，不能被其他文件引用
### 2. 引用---如果返回一个局部变量的引用，局部变量一定要加static放在全局区，栈区会被释放，不能继续继续调用
### 3. const 修饰成员函数（常函数）---放在()屁股后面，修饰this指针
1. 常函数内不可修改成员属性
2. 成员属性+mutable，常函数可以修改
> 常对象只能调用常函数
### 4. 继承：class 子类：继承方式 父类{}--->父私有继承了，但无法访问
* 虚继承--->解决多继承中父类资源重复的问题
  class Sheep::virtual public Animal{}
  > 底层是因为继承下来是vbptr，指向vbtable，表中记录了属性偏移量，加上偏移量指针指向基类属性
### 5. 文件
* 写
```cpp
ofstream ofs("路径","ios::方式: out/ate/app/trunc/binary")
```
* 读
```cpp
ifstream ifs;
//判断是否打开成功
ifs.open("路径","方式");
if (!ifs.open()){cout<<"false">>endl;}
string buf;
while (getline(ifs,buf)) cout<<buf<<endl;
ifs,flush();
ifs.close();
```
### 6. 泛型编程
* 类模板：template< class T1, class T2>
  > 普通类中成员函数一开始就创建了，类模板在调用时才创建

  > 类模板对象做含参，可以直接指定传入类型
  void printP(Person<string,int> &p){...;}

  > 参数模板化
  void printP(Person<T1,T2> &p){...;}

  > 整个类模板化
  template< class T >
  void printP(T &p)
* 类模板与继承---template< class T > --- class Base{T m}
  1. 当子类继承的父类是模板，子类声明时要指出父类T的数据类型
   class Son1:public Base< int >{}
  2. 如果想灵活指定父类T的类型，子类也变成模板 
   template < class T1, class T2 >
   class Son2:public Base<T2>{}
* 类模板成员函数类外实现
  template < class T1, class T2 >
  Person< T1, T2 >::Person(T1 name, T2 age){...;}
* 模板分文件编写---.hpp文件
  > 问题：类模板成员函数的创建时期是在函数调用阶段，分文件编写链接不到
### 7. 一些小的笔记
* toupper(ch)--->字符串转大写
* 右值的优点---传入不用去拷贝，直接传个匿名对象即可调用函数
    ```cpp
    void func(class animal){}
    ```
* 抛异常--->在程序运用的过程当中看看是否符合预期，如果不对，就抛出异常
  ```cpp
  #include <stdexpect>
  throw std::invalid_argument("require 100 arguments");
  // 如果想继续，捕捉
  try{
        func();
    }catch(const std::invalid_argument& e){
        // 看看异常原因
        cout<<"we catch it"<<e.what()<<endl;
    }
  
  ```
* stringstream解决字符串拆分问题
  ```cpp
  include<sstream>
  string s;//字符串定义
  stringstream ss(s); //创建流对象
  
  // 拆分字符串，放进vector
  string tmp; //存放临时拆分出来的字符串
  vector<string> vec;//存放拆分出来的字符串
  while (getline(ss,tmp," ")){
    if (tmp.empty()) continue;
    else if (temp!=" ") vec.push_back(temp);
  }

  // 计数
  int count = 0;
  string word;//收集字符串
  while (ss >> word){count++;}//流入word，会自动以空格分割
  ```
* int to string 
  ```cpp
  int a = 10;
  stringstream ss;
  ss << a;
  string str = ss.str();
  ```
* 进制转换
  ```cpp
  std::bitset（转2进制）----bitset<8>(36)
  std::oct（转8进制）
  std::dec （转10进制）
  std::hex（转16进制）
  ```
* s.substr(0,3)---从0位置开始割三个长度
* 判断元素是否存在
  ```cpp
  // string
  string str("abcd");
  if (str.find("bc")!=string::npos) cout<<"find!"<<endl;

  // vector
  std::find(vec.begin(),vec.end(),ele)

  // map / set 只想知道在不在，不需要位置
  m.count(ele)
  ```
* 比较器 cmp
  ```cpp
  sort(vec.begin(),vec.end(),std::greater<int>());//从大到小排
  
  //自己定义比较器
  bool cmp(const int& i1, const int& i2){
    return i1>i2;
  }

  // set 也可以排序，利用仿函数。但是在创建的时候就要告诉排序规则
  class cmp{
    public:
        bool operator()(const int& v1, const int& v2) return v1>v2;
  };
  set<int, cmp> my_set;
  ```
* map 存自定义类型+自定义比较器---一定要写hash_func
  ```cpp
  class A{
   poublic:
      int a_;
      A(int a) : a_(a){}
          
  };
  bool cmp(const A& c1, const A& c2){
      return c1.a_ > c2.a_;  
  }
  void func(){
      map<A, int, decltype(cmp)*> my_map(cmp);
      // key 自动排序
      my_map.insert({A(2),2});
      my_map.insert({A(5),5});
      my_map.insert({A(1),1});
      my_map.insert({A(3),3});
  }
  ```
* 动态内存管理
  ```cpp
  #include <memory>

  // 1. shared_pointer
  void func(){
    std::shared_ptr<int> ptr = std::make_shared<int>(22);
    std::shared_ptr<int> ptr1(ptr);//copy construction
    ptr.use_count();//2
    ptr1.use_count();//2
  }

  // 2. dangling pointer
  A* a = new A(22);
  {// 跳出这个区域，ptr已经被释放掉了，也就是说a没了
    std::shared_ptr<A> ptr(a);
  }
  cout<<a->a_<<endl;// 但是这里依然打印了a_

  // 3. smart pointer
  std::shared_ptr<int> ptr = std::make_shared<int>(22);
  // 按照传统的做法，如果进入一个选择分支语句，每一个里面都要写一个delete
  // 智能指针就不需要，因为离开了作用域，会自动释放
  // 也可以自己定义析构
  void destructAClass(A*a){
    delete a->a_;
  }
  std::shared_ptr<int> ptr(new A(22),destructAClass);

  // 4. unique_pointer
  std::unique_ptr<A> ptr = std::make_unique<A>(22);
  auto ptr = ptr.release();//指针释放了之后得有人接着，不然会放在那里，就是我不管它了
  // 仍然需要调用析构释放
  ptr->~A();
  ptr1.reset;//没人用直接删掉
  // 也可以自己走析构
  void destructionAClass(A* a){delete a->a_;};
  std::unique_ptr<A,decltype(destructionAClass)*> ptr1(new A(22),destructionAClass);//decltype(destructionAClass)* 是函数指针

  // 5. weak_pointer---没有权利控制对象的生命周期
  // 不会影响 shared_ptr 计数的值
  ```
  > unique_ptr 不能做显式拷贝，做函数返回值可以
* define 和 const 的区别
  1. define：预编译阶段处理的，没有类型和类型检查，遇到仅仅是展开，系统并不会为宏定义分配内存，从汇编的角度来说，以立即数保留了多份数据拷贝
  2. const: 编译期间处理的，有类型也有检查，会分配内存，从汇编上说，const常量在出现的地方保留的是真正的数据内存地址，只保留了一份拷贝，节省了不必要的内存空间。有时候编译器直接将const添加到符号表，省了读写内存的操作，效率更高
* 怎么检测内存泄漏
  1. linux swap观察还有多少可用的交换空间，一两分钟内键入三到四次，看看交换空间是否在减少
  2. netstat, vnstat，发现了波段有内存被分配而且从不释放，可能就泄漏了
  3. 内存调试工具valgrand
* 构造，析构函数可否抛异常
  构造中抛异常，析构不会被调用---内存泄漏
  用智能指针解决
  析构抛异常，没有进行当地catch，析构执行不全---如果还没有释放，内存泄漏
* 建立类的对象两种方式
  1. 静态建立：重载new，delete运算符为private,给禁用即可
  2. 动态建立：new一个对象malloc开辟空间然后构造对象。直接把构造和析构private掉，然后走public接口new对象
### 8. STL
* 迭代器不是指针，是类模板，迭代器是封装了指针，是一个可以遍历STL容器元素的对象，有着更高级的行为，比较++，--等。不用暴露集合内部结构的去遍历
### 9. C++11 新特性
* initializer_list---传递可变参数
  ```cpp
  #include <initializer_list>
  void func(std::initializer_list<int> initializer_list){
    for (int& num:initializer_list){
        cout << num<<endl;  
    }
  }
  int main(int arg, char** argv){
      func({1,2,3,4});
      func({5,7});
  }
  ```
* inline内联函数
  // 定义一个常量
  constexpr int Getsize(){return 42;}
  ```
  > 当函数体内部有递归，或者 static var ,不能使用
* emplace---不用拷贝和移动，直接在容器某个位置构造一个对象
* forward_list
  ```cpp
  #include <forward_list>
  // 删除值为偶数节点
  forward_list<int> my_list = {1,2,3,4,5,6};//initialization list
  forward_list<int>::iterator prev = my_list.before_begin();
  forward_list<int>::iterator cur = my_list.begin();
  while(cur!=my_list.end()){
    if (*cur%2==0){
        cur = my_list.erase_after(prev);//返回的是下一个元素
    }else{
        prev = cur;
        cur++;
    }
  }
  ```
* lambda expression---类似匿名函数的特性，重载小括号，此时类的对象具有类似函数的行为，仿函数
  generate 匿名类, 重载小括号
  > 格式：[capture list &x](paremeter list)->return type{func_body};
  重要应用：用于函数参数，实现回调函数
* override
  > 覆盖一个方法，并对其重写，用于派生类，是一个继承控制关键字
  确保在派生类中声明的重载函数跟基类的虚函数有相同的声明(会检查两个函数签名是否匹配，不匹配会出现编译问题)
  ```cpp
  void func() override{};
  ```
* volatile---我要保证我的执行，你编译器不要给我乱优化。
  1. 中断程序修改的某个变量的值
  2. 多线程共享的一个变量标志
  3. 硬件存储器的输入出端口，保证读写正确
   > 没有原子性和可见性，多线程环境下不能保证数据同步一致，需要和互斥锁，信号量，内存屏障等配合
* 右值引用---允许修改右值，实现move语义
  原先：构造左值，再析构右值
  现在：直接拿数据过来修改左值
* 泛化常量表达式
  constexpr int N = 5;
  int arr[N];
* decltype
  自动推导一个类型
  和auto的区别：
  * auto根据变量的初始值来判断类型，decltype根据表达式判断类型
  * auto会忽略顶层const和引用，decltype是保留的
  * auto不能用于函数声明时没有初始值的参数，decltype可以
  * auto可用于lambda表达式和结构化绑定中推断返回值或者绑定变量的类型，decltype不可以
* 多线程编程
* 线程同步(互斥锁)---独占，递归，超时，超时递归
* 条件变量---睡眠，唤醒
* =delete 删除函数