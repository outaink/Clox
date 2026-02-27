#ifndef clox_vm_h
#define clox_vm_h

#include "object.h"
#include "table.h"
#include "value.h"

#define FRAMES_MAX 64
#define STACK_MAX (FRAMES_MAX * UINT8_COUNT)

/*
 * CallFrame 代表一次函数调用。
 * 它记录了当前执行的闭包、指令指针（ip）以及该函数在 VM 栈中的起始位置（slots）。
 */
typedef struct {
  ObjClosure *closure; // 当前调用的闭包
  uint8_t *ip;         // 指向当前正在执行的字节码指令
  Value *slots;        // 指向该帧在虚拟机栈上的第一个槽位（局部变量开始的地方）
} CallFrame;

/*
 * VM 结构体是 Lox 虚拟机的核心。
 * 它维护了程序运行时的所有状态，包括调用栈、操作数栈、全局变量等。
 */
typedef struct {
  // 调用帧数组：模拟函数调用栈。
  CallFrame frames[FRAMES_MAX]; 
  int frameCount; // 当前活跃的调用帧数量

  // 操作数栈：用于存储临时值、函数参数和表达式计算结果。
  Value stack[STACK_MAX]; 
  Value *stackTop; // 始终指向栈中下一个可用槽位的指针

  Table globals; // 存储全局变量的哈希表
  Table strings; // 字符串驻留表，确保相同的字符串只存储一份

  // Upvalue 链表：用于管理闭包捕获的、且仍在栈上的变量。
  ObjUpvalue* openUpvalues; 

  // GC 链表：记录所有在堆上分配的对象，以便垃圾回收器追踪。
  Obj *objects;  
} VM;

typedef enum {
  INTERPRET_OK,
  INTERPRET_COMPILE_ERROR,
  INTERPRET_RUNTIME_ERROR
} InterpretResult;

extern VM vm;

void initVM();
void freeVM();
InterpretResult interpret(const char *source);
void push(Value value);
Value pop();

#endif