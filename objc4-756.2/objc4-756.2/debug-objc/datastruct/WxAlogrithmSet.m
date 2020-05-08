//
//  WxAlogrithmSet.m
//  debug-objc
//
//  Created by wqa on 2018/10/30.
//

#import "WxAlogrithmSet.h"

@implementation WxAlogrithmSet

+ (void)startTest {
    NSTimeInterval srandkey = [[NSDate date] timeIntervalSince1970];
    srand([NSNumber numberWithDouble:srandkey].unsignedIntegerValue);
    NSMutableArray *orginArr = [NSMutableArray arrayWithCapacity:100];
    for (int i = 0; i < 100; ++i) {
        orginArr[i] = [NSNumber numberWithInt:rand() % 1000];
    }
    NSMutableArray *sortedArr = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray *revertdArr = [NSMutableArray arrayWithCapacity:100];
    for (int i = 0; i < 100; ++i) {
        sortedArr[i] = [NSNumber numberWithInt:i];
        revertdArr[i] = [NSNumber numberWithInt:100-i];
    }
    
    NSMutableArray *quckArr = [NSMutableArray arrayWithArray:revertdArr];
    [self quickSort:quckArr low:0 high:quckArr.count];
    [self PrintArr:quckArr];
    
    NSMutableArray *heapArr = [NSMutableArray arrayWithArray:orginArr];
    [self heapSort:heapArr];
    [self PrintArr:heapArr];
    
    NSMutableArray *mergerArr = [NSMutableArray arrayWithArray:orginArr];
    [self mergerSort:mergerArr low:0 high:mergerArr.count tmpArr:heapArr];
    [self PrintArr:mergerArr];
    
    NSMutableArray *selectSortSortArr = [NSMutableArray arrayWithArray:orginArr];
    [self selectSort:selectSortSortArr low:0 high:selectSortSortArr.count];
    [self PrintArr:selectSortSortArr];
    
    NSMutableArray *insertSortArr = [NSMutableArray arrayWithArray:orginArr];
    [self insertSort:insertSortArr low:0 high:insertSortArr.count];
    [self PrintArr:insertSortArr];
    
    NSMutableArray *bubbleSortSortArr = [NSMutableArray arrayWithArray:orginArr];
    [self bubbleSort:bubbleSortSortArr low:0 high:bubbleSortSortArr.count];
    [self PrintArr:bubbleSortSortArr];
    
    NSInteger a = [self binarySearch:bubbleSortSortArr data:@10000];
    NSInteger b = [self binarySearch:bubbleSortSortArr data:bubbleSortSortArr[20]];
    NSInteger c = [self binarySearch:bubbleSortSortArr data:bubbleSortSortArr[99]];
    NSInteger d = [self binarySearch:bubbleSortSortArr data:bubbleSortSortArr[0]];
}

+ (void)PrintArr:(NSMutableArray<NSNumber *> *)arr {
    NSMutableString *result = [NSMutableString stringWithFormat:@"\n"];
    for (NSInteger idx = 0; idx < arr.count; ++idx) {
        NSNumber *data = arr[idx];
        if (idx > 0) {
            assert(data >= arr[idx-1] && arr.count == 100);
        }
        [result appendFormat:@"%@    ", data];
        if (idx % 10 == 9) {
            [result appendFormat:@"\n"];
        }
    }
    NSLog(@"%@", result);
}

+ (void)swapValue:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high {
    NSNumber *tmp = arr[low];
    arr[low] = arr[high];
    arr[high] = tmp;
}

+ (void)quickSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high {
    if (low >= high) {
        return;
    }
    NSInteger left = low, right = high - 1;
    NSNumber *key = arr[low];
    while (left < right) {
        while (right > left && arr[right] >= key) {
            --right;
        }
        arr[left] = arr[right];
        while (left < right && arr[left] <= key) {
            ++left;
        }
        arr[right] = arr[left];
    }
    arr[left] = key;
    [self quickSort:arr low:low high:left];
    [self quickSort:arr low:left+1 high:high];
}

#pragma mark heap-sort
+ (void)headAdjustMax:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high {
#define leftChid(x) ((2 * x) + 1)
    NSInteger child;
    NSNumber *tmp = arr[low];
    for (; leftChid(low) < high; low = child) {
        child = leftChid(low);
        if ((child + 1) < high && arr[child] < arr[child+1]) {
            child = child + 1;
        }
        if (tmp < arr[child]) {
            arr[low] = arr[child];
        }
        else {
            break;
        }
    }
    arr[low] = tmp;
    
}

+ (void)heapSort:(NSMutableArray<NSNumber *> *)arr {
    NSInteger len = arr.count;
    for (int i = len/2 - 1; i >= 0; --i) {
        [self headAdjustMax:arr low:i high:len];
    }
    for (int i = len-1; i >= 0; --i) {
        [self swapValue:arr low:0 high:i];
        [self headAdjustMax:arr low:0 high:i];
    }
}

#pragma merger-sort
+ (void)mergerArr:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low mid:(NSInteger)mid high:(NSInteger)high tmpArr:(nonnull SortDataArr *)tmpArr {
    int left = low, j = mid, k = 0;
    while (left < mid && j < high) {
        if (arr[left] <= arr[j]) {
            tmpArr[k++] = arr[left++];
        }
        else {
            tmpArr[k++] = arr[j++];
        }
    }
    while (left < mid) {
        tmpArr[k++] = arr[left++];
    }
    while (j < high) {
        tmpArr[k++] = arr[j++];
    }
    
    for (int i = 0; i < k; i++) {
        arr[low+i] = tmpArr[i];
    }
}

+ (void)mergerSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high tmpArr:(nonnull SortDataArr *)tmpArr{
    //high = arr.len
    if (low + 2 == high) {
        if (arr[low] > arr[low+1]) {
            [self swapValue:arr low:low high:low+1];
        }
    }
    else if (low + 1 < high) {
        NSInteger mid = (low + high) / 2;
        [self mergerSort:arr low:low high:mid tmpArr:tmpArr];
        [self mergerSort:arr low:mid high:high tmpArr:tmpArr];
        [self mergerArr:arr low:low mid:mid high:high tmpArr:tmpArr];
    }
}

+ (void)insertSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high {
    for (int i = low + 1; i < high; i++) {
        NSNumber *temp = arr[i];
        int j = i;
        while (j > low && arr[j - 1] > temp) {
            arr[j] = arr[j-1];
            --j;
        }
        if (j != i-1) {
            arr[j] = temp;
        }
        
    }
}

+ (void)selectSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high {
    for (int i = low; i < high; ++i) {
        NSInteger min = i;
        for (int j = i+1; j < high; ++j) {
            if (arr[j] < arr[min]) {
                min = j;
            }
        }
        if (i != min) {
            [self swapValue:arr low:i high:min];
        }
    }
}

+ (void)bubbleSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high {
    for (int i = low; i < high; ++i) {
        BOOL noSwap = YES;
        for (int j = low; j < high - i - 1; ++j) {
            if (arr[j] > arr[j+1]) {
                [self swapValue:arr low:j high:j+1];
                noSwap = NO;
            }
        }
        if (noSwap) {
            break;
        }
    }
}

+ (NSInteger)binarySearch:(SortDataArr *)arr data:(NSNumber *)data {
    
    NSInteger left = 0, right = arr.count, mid;
    while (left < right) {
        mid = (left + right)/2;
        if (arr[mid] == data) {
            return mid;
        }
        if (data > arr[mid]) {
            left = mid + 1;
        }
        else {
            right = mid - 1;
        }
    }
    return -1;
    
}

@end
