//
//  ViewController.m
//  JsonFormatApp
//
//  Created by 廉鑫博 on 2017/6/12.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "ViewController.h"
#import "ESClassInfo.h"

#import "ESJsonFormatSetting.h"
#import "ESDialogController.h"
@interface ViewController ()

@property (weak) IBOutlet NSScrollView *inputView;

@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;


@property (weak) IBOutlet NSScrollView *outputView;

@property (weak) IBOutlet NSButton *enterButton;
@property (weak) IBOutlet NSButton *cancelButton;


@property (weak, nonatomic)NSString *propertyContent;
/**
 *  字段对应的类的名字[key->JSON字段 : value->类名(用户输入)]
 */
@property (nonatomic, strong) NSMutableDictionary *replaceClassNames;

@end
@implementation ViewController
-(NSMutableDictionary *)replaceClassNames{
    if (!_replaceClassNames) {
        _replaceClassNames = [NSMutableDictionary dictionary];
    }
    return _replaceClassNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear
{
    [super viewWillAppear];
    [self.inputView becomeFirstResponder];
}
- (IBAction)enterButtonClick:(id)sender {
    
    NSTextView *textView = self.inputTextView;
    id result = [self dictionaryWithJsonStr:textView.string];
    if ([result isKindOfClass:[NSError class]]) {
        NSError *error = result;
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        NSLog(@"Error：Json is invalid");
    }else{
        
        ESClassInfo *classInfo = [self dealClassNameWithJsonResult:result];
        [self.outputTextView insertText:[NSString stringWithFormat:@"%@\n%@",classInfo.propertyContent,classInfo.classInsertTextViewContentForH] replacementRange:NSMakeRange(0, classInfo.propertyContent.length + classInfo.classInsertTextViewContentForH.length)];
    
    }

}

- (IBAction)cancelButtonClick:(id)sender {
    self.inputTextView.string  = @"";
    self.outputTextView.string = @"";
}
/**
 *  检查是否是一个有效的JSON
 */
-(id)dictionaryWithJsonStr:(NSString *)jsonString{
    jsonString = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"jsonString=%@",jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dicOrArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&err];
    if (err) {
        return err;
    }else{
        return dicOrArray;
    }
    
}/**
  *  初始类名，RootClass/JSON为数组/创建文件与否
  *
  *  @param result JSON转成字典或者数组
  *
  *  @return 类信息
  */
- (ESClassInfo *)dealClassNameWithJsonResult:(id)result{
    __block ESClassInfo *classInfo = nil;
    //如果当前是JSON对应是字典
    if ([result isKindOfClass:[NSDictionary class]]) {
        //如果是生成到文件，提示输入Root class name
        if ([ESJsonFormatSetting defaultSetting].outputToFiles) {
            ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The root class for output to files name is:"];
            [dialog setDataWithMsg:msg defaultClassName:ESRootClassName enter:^(NSString *className) {
                classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:className classDic:result];
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            [self dealPropertyNameWithClassInfo:classInfo];
        }else{
            //不生成到文件，Root class 里面用户自己创建
            classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:ESRootClassName classDic:result];
            [self dealPropertyNameWithClassInfo:classInfo];
        }
    }else if([result isKindOfClass:[NSArray class]]){
        if ([ESJsonFormatSetting defaultSetting].outputToFiles) {
            //当前是JSON代表数组，生成到文件需要提示用户输入Root Class name，
            ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The root class for output to files name is:"];
            __block NSString *rootClassName = ESRootClassName;
            [dialog setDataWithMsg:msg defaultClassName:ESRootClassName enter:^(NSString *className) {
                rootClassName = className;
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            
            //并且提示用户输入JSON对应的key的名字
            dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            msg = [NSString stringWithFormat:@"The JSON is an array,the correspond 'key' is:"];
            [dialog setDataWithMsg:msg defaultClassName:ESArrayKeyName enter:^(NSString *className) {
                //输入完毕之后，将这个class设置
                NSDictionary *dic = [NSDictionary dictionaryWithObject:result forKey:className];
                classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:rootClassName classDic:dic];
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            [self dealPropertyNameWithClassInfo:classInfo];
        }else{
            //Root class 已存在，只需要输入JSON对应的key的名字
            ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The JSON is an array,the correspond 'key' is:"];
            [dialog setDataWithMsg:msg defaultClassName:ESArrayKeyName enter:^(NSString *className) {
                //输入完毕之后，将这个class设置
                NSDictionary *dic = [NSDictionary dictionaryWithObject:result forKey:className];
                classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:ESRootClassName classDic:dic];
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            [self dealPropertyNameWithClassInfo:classInfo];
        }
    }
    return classInfo;
}


/**
 *  处理属性名字(用户输入属性对应字典对应类或者集合里面对应类的名字)
 *
 *  @param classInfo 要处理的ClassInfo
 *
 *  @return 处理完毕的ClassInfo
 */
- (ESClassInfo *)dealPropertyNameWithClassInfo:(ESClassInfo *)classInfo{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:classInfo.classDic];
    for (NSString *key in dic) {
        //取出的可能是NSDictionary或者NSArray
        id obj = dic[key];
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
            NSString *msg = [NSString stringWithFormat:@"The '%@' correspond class name is:",key];
            if ([obj isKindOfClass:[NSArray class]]) {
                //May be 'NSString'，will crash
                if (!([[obj firstObject] isKindOfClass:[NSDictionary class]] || [[obj firstObject] isKindOfClass:[NSArray class]])) {
                    continue;
                }
                dialog.objIsKindOfArray = YES;
                msg = [NSString stringWithFormat:@"The '%@' child items class name is:",key];
            }
            __block NSString *childClassName;//Record the current class name
            [dialog setDataWithMsg:msg defaultClassName:[key capitalizedString] enter:^(NSString *className) {
                if (![className isEqualToString:key]) {
                    self.replaceClassNames[key] = className;
                }
                childClassName = className;
            }];
            [NSApp beginSheet:[dialog window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            [NSApp runModalForWindow:[dialog window]];
            //如果当前obj是 NSDictionary 或者 NSArray，继续向下遍历
            if ([obj isKindOfClass:[NSDictionary class]]) {
                ESClassInfo *childClassInfo = [[ESClassInfo alloc] initWithClassNameKey:key ClassName:childClassName classDic:obj];
                [self dealPropertyNameWithClassInfo:childClassInfo];
                //设置classInfo里面属性对应class
                [classInfo.propertyClassDic setObject:childClassInfo forKey:key];
            }else if([obj isKindOfClass:[NSArray class]]){
                //如果是 NSArray 取出第一个元素向下遍历
                NSArray *array = obj;
                if (array.firstObject) {
                    NSObject *obj = [array firstObject];
                    //May be 'NSString'，will crash
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        ESClassInfo *childClassInfo = [[ESClassInfo alloc] initWithClassNameKey:key ClassName:childClassName classDic:(NSDictionary *)obj];
                        [self dealPropertyNameWithClassInfo:childClassInfo];
                        //设置classInfo里面属性类型为 NSArray 情况下，NSArray 内部元素类型的对应的class
                        [classInfo.propertyArrayDic setObject:childClassInfo forKey:key];
                    }
                }
            }
        }
    }
    return classInfo;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
