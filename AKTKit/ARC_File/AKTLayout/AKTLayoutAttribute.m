//
//  AKTLayoutAttribute.c
//  AKTLayout
//
//  Created by YaHaoo on 16/4/15.
//  Copyright © 2016年 YaHaoo. All rights reserved.
//

#import "AKTLayoutAttribute.h"
// import-<frameworks.h>

// import-"models.h"
#import "UIView+AKTLayout.h"
#import "AKTPublic.h"
// import-"views & controllers.h"

//--------------------Structs statement, globle variables...--------------------
typedef struct {
    float top, left, bottom, right, width, height, whRatio, centerX, centerY;
}AKTLayoutParam;
typedef AKTLayoutParam *AKTLayoutParamRef;
//-------------------- E.n.d -------------------->Structs statement, globle variables...

#pragma mark - function definition
//|---------------------------------------------------------
/**
 *  Create a layout attribute item according to the attribute item type.
 *  根据类型创建布局项
 *
 *  @param attribute Layout attribute.
 *  @param attribute 布局对象
 *  @param itemType  Attribute item type.
 *  @param itemType  布局项类型
 *
 */
bool createItem(AKTAttributeItemType itemType);
/*
 * Parse layout item to layout param
 */
void parseItem(AKTAttributeItemRef itemRef, AKTLayoutParamRef paramRef);

/*
 * Rect generated by infor in param
 */
CGRect calculateRect(AKTLayoutParamRef paramRef, AKTLayoutAttributeRef attributeRef);

/*
 * According to param, calculate the size of frame in horizontal direction. When you call the method, please ensure there were no redundant configurations in param.
 * In one direction two configurations in addition to "whRatio" is enough to calculate the frame in that direction. WhRation will be convert to the configuration of width or height
 * @oRect : The frame of the view which will be layout according to the reference view was got before layout
 */
CGRect horizontalCalculation(AKTLayoutParamRef paramRef, CGRect oRect);

/*
 * According to param, calculate the size of frame in vertical direction. When you call the method, please ensure there were no redundant configurations in param.
 * In one direction two configurations in addition to "whRatio" is enough to calculate the frame in that direction. WhRation will be convert to the configuration of width or height
 * @oRect : The frame of the view which will be layout according to the reference view was got before layout
 */
CGRect verticalCalculation(AKTLayoutParamRef paramRef, CGRect oRect);

/*
 * The param has no configuration for whRatio, return the rect
 */
CGRect rectNoWhRatio(AKTLayoutParamRef paramRef, AKTLayoutAttributeRef attributeRef);

/*
 * The param has the configuration for whRatio, return the rect
 */
CGRect rectWhRatio(AKTLayoutParamRef paramRef, AKTLayoutAttributeRef attributeRef);

#pragma mark - life cycle
//|---------------------------------------------------------
/**
 *  Initialize AKTLayoutAttribute.
 *  初始化
 *
 *  @param view      The view need to be layout
 *  @param view      需要被布局的视图
 */
void aktLayoutAttributeInit(UIView *view) {
    attributeRef_global->itemCount = 0;
    attributeRef_global->bindView = (__bridge const void *)(view);
    attributeRef_global->check = false;
}

AKTLayoutParam initializedParamInfo() {
    return (AKTLayoutParam){
        .top     = FLT_MAX,
        .left    = FLT_MAX,
        .bottom  = FLT_MAX,
        .right   = FLT_MAX,
        .width   = FLT_MAX,
        .height  = FLT_MAX,
        .whRatio = FLT_MAX,
        .centerX = FLT_MAX,
        .centerY = FLT_MAX
    };
}

#pragma mark - create item
//|---------------------------------------------------------
/**
 *  Create layout attribute item.
 *  创建布局项.
 *
 */
bool __akt__create__top() {
    return createItem(AKTAttributeItemType_Top);
}

bool __akt__create__left() {
    return createItem(AKTAttributeItemType_Left);
}

bool __akt__create__bottom() {
    return createItem(AKTAttributeItemType_Bottom);
}

bool __akt__create__right() {
    return createItem(AKTAttributeItemType_Right);
}

bool __akt__create__width() {
    return createItem(AKTAttributeItemType_Width);
}

bool __akt__create__height() {
    return createItem(AKTAttributeItemType_Height);
}

bool __akt__create__whRatio() {
    return createItem(AKTAttributeItemType_WHRatio);
}

bool __akt__create__centerX() {
    return createItem(AKTAttributeItemType_CenterX);
}

bool __akt__create__centerY() {
    return createItem(AKTAttributeItemType_CenterY);
}

bool __akt__create__centerXY() {
    return createItem(AKTAttributeItemType_CenterXY);
}

bool __akt__create__edge() {
    // Check whether out of range
    if (attributeRef_global->itemCount==kItemMaximum) {
        UIView *view = (__bridge UIView *)(attributeRef_global->bindView);
        mAKT_Log(@"%@: %@\nOut of the range of attributeItem array",[view class], view.aktName);
        return false;
    }
    AKTAttributeItemRef itemRef = attributeRef_global->itemArray+attributeRef_global->itemCount;
    aktAttributeItemInit(itemRef);
    attributeRef_global->itemCount++;
    // Set bindView
    itemRef->bindView = attributeRef_global->bindView;
    // Add itemType to item
    itemRef->configuration.referenceEdgeInsert = UIEdgeInsetsMake(0, 0, 0, 0);
    //    itemRef->typeCount++;
    return true;
}

bool __akt__create__size() {
    // Check whether out of range
    if (attributeRef_global->itemCount==kItemMaximum) {
        UIView *view = (__bridge UIView *)(attributeRef_global->bindView);
        mAKT_Log(@"%@: %@\nOut of the range of attributeItem array",[view class], view.aktName);
        return false;
    }
    AKTAttributeItemRef itemRef = attributeRef_global->itemArray+attributeRef_global->itemCount;
    aktAttributeItemInit(itemRef);
    attributeRef_global->itemCount++;
    // Set bindView
    itemRef->bindView = attributeRef_global->bindView;
    // Add itemType to item
    itemRef->configuration.reference.referenceSize = CGSizeMake(0, 0);
    //    itemRef->typeCount++;
    return true;
}

/**
 *  Create a layout attribute item according to the attribute item type.
 *  根据类型创建布局项
 *
 *  @param itemType  Attribute item type.
 *  @param itemType  布局项类型
 *
 */
bool createItem(AKTAttributeItemType itemType) {
    // Check whether out of range
    if (attributeRef_global->itemCount==kItemMaximum) {
        UIView *view = (__bridge UIView *)(attributeRef_global->bindView);
        mAKT_Log(@"%@: %@\nOut of the range of attributeItem array",[view class], view.aktName);
        return false;
    }
    AKTAttributeItemRef itemRef = attributeRef_global->itemArray+attributeRef_global->itemCount;
    aktAttributeItemInit(itemRef);
    attributeRef_global->itemCount++;
    // Set bindView
    itemRef->bindView = attributeRef_global->bindView;
    // Add itemType to item
    itemRef->typeArray[itemRef->typeCount] = itemType;
    itemRef->typeCount++;
    return true;
}

#pragma mark - function implementations
//|---------------------------------------------------------
/*
 * Calculate layout with the infor from the attribute items, return CGRect
 * Configurations in AKTLayoutParam, as follows configurations can be divided into vertical and horizontal direction
 * In one direction two configurations in addition to "whRatio" is enough to calculate the frame in that direction. WhRation will be convert to the configuration of width or height
 * ________________________________________
 * |    verticcal    |     horizontal     |
 * |       top       |        left        |
 * |      bottom     |        right       |
 * |      height     |        width       |
 * |     centerY     |       centerX      |
 * |    >whRatio<    |      >whRatio<     |
 * |_________________|____________________|
 */
CGRect calculateAttribute(AKTLayoutAttributeRef attributeRef) {
    // Filter out invalid layout items
    UIView *bindView = (__bridge UIView *)(attributeRef->bindView);
    if (!attributeRef->check) {
        if (attributeRef->itemCount == 0) {
            mAKT_Log(@"%@: %@\nNot added any attribute items",[bindView class], bindView.aktName);
            return bindView.frame;
        }
        // 去除无效布局项
        int valideItemCount = 0;
        for (int i = 0; i<attributeRef->itemCount; i++) {
            AKTAttributeItemRef itemRef = attributeRef->itemArray+i;
            if (itemRef->configuration.reference.referenceValidate == false) {
                continue;
            }else{
                attributeRef->itemArray[valideItemCount] = *itemRef;
                valideItemCount++;
            }
        }
        attributeRef->itemCount = valideItemCount;
    }
    // 如果定义了edge inset 则忽略其余配置信息
    {
        // Find which item set the edgeInset
        UIEdgeInsets edgeInset;
        UIView *referenceView;
        AKTAttributeItemRef itemRef = NULL;
        for (int i = 0; i<attributeRef->itemCount; i++) {
            itemRef = attributeRef->itemArray+i;
            edgeInset = itemRef->configuration.referenceEdgeInsert;
            referenceView = (__bridge UIView *)(itemRef->configuration.reference.referenceView);
            // Calculate frame
            if (referenceView && edgeInset.top<FLT_MAX-1) {
                CGFloat x_i, y_i,w_i,h_i;
                CGRect viewRec = [bindView.superview convertRect:referenceView.frame fromView:referenceView.superview? referenceView.superview:mAKT_APPDELEGATE.keyWindow];
                x_i = viewRec.origin.x+calculate(edgeInset.left, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                y_i = viewRec.origin.y+calculate(edgeInset.top, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                w_i = -calculate(edgeInset.left, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset)+viewRec.size.width-calculate(edgeInset.right, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                h_i = -calculate(edgeInset.top, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset)+viewRec.size.height-calculate(edgeInset.bottom, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                // If the layout of the first run.
                // 如果布局首次运行
                if (!attributeRef->check) {
                    // Optimization attribute Ref remove redundant data entry.
                    // 优化attributeRef移除多余的布局项
                    attributeRef->itemArray[0] = *itemRef;
                    attributeRef->itemCount = 1;
                    // Add layout chain
                    // 添加布局链
                    UIView *bindView = (__bridge UIView *)(attributeRef->bindView);
                    [referenceView.layoutChain addObject:bindView.aktContainer];
                    [bindView.viewsReferenced addObject:referenceView.aktContainer];
                }
                return CGRectMake(x_i, y_i, w_i, h_i);
            }
        }
    }
    // Filter layout setting information.(size, whRatio, recalculation)
    // 过滤布局设置信息(size, whRatio, recalculation)
    AKTLayoutParam paramInfo = initializedParamInfo();
    static id tempArr = nil;
    NSMutableArray *viewReferenceTmp = tempArr;
    if (viewReferenceTmp) {
        [viewReferenceTmp removeAllObjects];
    }else{
        viewReferenceTmp = [NSMutableArray array];
        tempArr = viewReferenceTmp;
    }
    // Get whRatio if exist
    for (int i = 0; i<attributeRef->itemCount; i++) {
        AKTAttributeItemRef itemRef = attributeRef->itemArray+i;
        // 获取保存参照视图
        if (!attributeRef->check) {
            // Get layout reference view
            // 获取布局参考视图
            UIView *referenceView = nil;
            if(itemRef->configuration.reference.referenceType == AKTRefenceType_View) {
                referenceView = (__bridge UIView *)(itemRef->configuration.reference.referenceView);
                if(![viewReferenceTmp containsObject:referenceView]) [viewReferenceTmp addObject:referenceView];
            }else if (itemRef->configuration.reference.referenceType == AKTRefenceType_ViewAttribute) {
                referenceView = (__bridge UIView *)(itemRef->configuration.reference.referenceAttribute.referenceView);
                if(![viewReferenceTmp containsObject:referenceView]) [viewReferenceTmp addObject:referenceView];
            }
        }
        // If we configured "equaltoSize", set the view's size directly. You can only set size in the chain, set another position constraint is invalid.
        // 如果是设置了size,则直接设置view的size,在设置size的链中只能设置size，设置其它位置约束是无效的
        CGSize size = itemRef->configuration.reference.referenceSize;
        if(size.width<FLT_MAX-1) {
            if (itemRef->configuration.reference.referenceType == AKTRefenceType_View) {
                UIView *referenceView = (__bridge UIView *)(itemRef->configuration.reference.referenceView);
                itemRef->configuration.reference.referenceSize = referenceView.frame.size;
            }
            size = itemRef->configuration.reference.referenceSize;
            paramInfo.width = calculate(size.width, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
            paramInfo.height = calculate(size.height, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
            continue;
        }
        // 如果没有设置size则查找是否设置whRatio，后面会根据有无whRatio分别处理
        for (int j = 0; j<itemRef->typeCount; j++) {
            int num = itemRef->typeArray[j];
            if (num == AKTAttributeItemType_WHRatio) {
                if (itemRef->configuration.reference.referenceType == AKTRefenceType_Constant) {
                    paramInfo.whRatio = itemRef->configuration.reference.referenceValue;
                }else{
                    UIView *v = (__bridge UIView *)(itemRef->configuration.reference.referenceView);
                    paramInfo.whRatio = calculate(v.width/v.height, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                }
            }
        }
    }
    // Add layout chain
    // 添加布局链
    if (!attributeRef->check) {
        for (UIView *referenceView in viewReferenceTmp) {
            [referenceView.layoutChain addObject:bindView.aktContainer];
            [bindView.viewsReferenced addObject:referenceView.aktContainer];
        }
    }
    // Set other itemtypes: top/left/width.... into paramInfo
    for (int i = 0; i<attributeRef->itemCount; i++) {
        AKTAttributeItemRef itemRef = attributeRef->itemArray+i;
        parseItem(itemRef, &paramInfo);
    }
    return calculateRect(&paramInfo, attributeRef);
}

#pragma mark - aid for frame calculation
//|---------------------------------------------------------
/*
 * Parse layout item to layout param
 */
void parseItem(AKTAttributeItemRef itemRef, AKTLayoutParamRef paramRef) {
    // All of the layout types in the array
    for (int i = 0; i<itemRef->typeCount; i++) {
        int num = itemRef->typeArray[i];
        // If we configured other position constraints do different treatment by differentiating the reference type of constraints.
        // 如果设置了其它的位置约束, 通过区分约束参考类型来做不同的处理
        if (itemRef->configuration.reference.referenceType == AKTRefenceType_Constant) {
            float result = calculate(itemRef->configuration.reference.referenceValue, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
            switch (itemRef->typeArray[i]) {
                case AKTAttributeItemType_Top:
                {
                    paramRef->top = result;
                    break;
                }
                case AKTAttributeItemType_Left:
                {
                    paramRef->left = result;
                    break;
                }
                case AKTAttributeItemType_Bottom:
                {
                    paramRef->bottom = result;
                    break;
                }
                case AKTAttributeItemType_Right:
                {
                    paramRef->right = result;
                    break;
                }
                case AKTAttributeItemType_Width:
                {
                    if (paramRef->width<FLT_MAX-1 && !mAKT_EQ(paramRef->width, result)) {
                        UIView *bindView = (__bridge UIView *)(itemRef->bindView);
                        mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: width", bindView.aktName);
                    }
                    paramRef->width = result;
                    break;
                }
                case AKTAttributeItemType_Height:
                {
                    if (paramRef->height<FLT_MAX-1 && !mAKT_EQ(paramRef->height, result)) {
                        UIView *bindView = (__bridge UIView *)(itemRef->bindView);
                        mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: height", bindView.aktName);
                    }
                    paramRef->height = result;
                    break;
                }
                case AKTAttributeItemType_CenterX:
                {
                    paramRef->centerX = result;
                    break;
                }
                case AKTAttributeItemType_CenterY:
                {
                    paramRef->centerY = result;
                    break;
                }
                case AKTAttributeItemType_CenterXY:
                {
                    paramRef->centerY = paramRef->centerX = result;
                    break;
                }
                default:
                    break;
            }
        }else if(itemRef->configuration.reference.referenceType == AKTRefenceType_View){
            UIView *v = (__bridge UIView *)(itemRef->configuration.reference.referenceView);
            UIView *bindView = (__bridge UIView *)(itemRef->bindView);
            CGRect viewRec = [bindView.superview convertRect:v.frame fromView:v.superview? v.superview:mAKT_APPDELEGATE.keyWindow];
            switch (num) {
                case AKTAttributeItemType_Top:
                {
                    paramRef->top = calculate(viewRec.origin.y, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    break;
                }
                case AKTAttributeItemType_Left:
                {
                    paramRef->left = calculate(viewRec.origin.x, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    break;
                }
                case AKTAttributeItemType_Bottom:
                {
                    paramRef->bottom = calculate(viewRec.origin.y+viewRec.size.height, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    break;
                }
                case AKTAttributeItemType_Right:
                {
                    paramRef->right = calculate(viewRec.origin.x+viewRec.size.width, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    break;
                }
                case AKTAttributeItemType_Width:
                {
                    CGFloat result = calculate(viewRec.size.width, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    if (paramRef->width<FLT_MAX-1 && !mAKT_EQ(paramRef->width, result)) {
                        UIView *bindView = (__bridge UIView *)(itemRef->bindView);
                        mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: width", bindView.aktName);
                    }
                    paramRef->width = result;
                    
                    break;
                }
                case AKTAttributeItemType_Height:
                {
                    CGFloat result = calculate(viewRec.size.height, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    if (paramRef->height<FLT_MAX-1 && !mAKT_EQ(paramRef->height, result)) {
                        UIView *bindView = (__bridge UIView *)(itemRef->bindView);
                        mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: height", bindView.aktName);
                    }
                    paramRef->height = result;
                    break;
                }
                case AKTAttributeItemType_CenterX:
                {
                    paramRef->centerX = calculate(viewRec.origin.x+viewRec.size.width/2, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    break;
                }
                case AKTAttributeItemType_CenterY:
                {
                    paramRef->centerY = calculate(viewRec.origin.y+viewRec.size.height/2, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    break;
                }
                case AKTAttributeItemType_CenterXY:
                {
                    paramRef->centerX = calculate(viewRec.origin.x+viewRec.size.width/2, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    paramRef->centerY = calculate(viewRec.origin.y+viewRec.size.height/2, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
                    break;
                }
                default:
                    break;
            }
        }else{
            UIView *bindView = (__bridge UIView *)(itemRef->bindView);
            float result = getValue(itemRef->configuration.reference.referenceAttribute, bindView);
            result = calculate(result, itemRef->configuration.referenceMultiple, itemRef->configuration.referenceOffset);
            switch (num) {
                case AKTAttributeItemType_Top:
                {
                    paramRef->top = result;
                    break;
                }
                case AKTAttributeItemType_Left:
                {
                    paramRef->left = result;
                    break;
                }
                case AKTAttributeItemType_Bottom:
                {
                    paramRef->bottom = result;
                    break;
                }
                case AKTAttributeItemType_Right:
                {
                    paramRef->right = result;
                    break;
                }
                case AKTAttributeItemType_Width:
                {
                    if (paramRef->width<FLT_MAX-1 && !mAKT_EQ(paramRef->width, result)) {
                        mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: width", bindView.aktName);
                    }
                    paramRef->width = result;
                    break;
                }
                case AKTAttributeItemType_Height:
                {
                    if (paramRef->height<FLT_MAX-1 && !mAKT_EQ(paramRef->height, result)) {
                        mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: height", bindView.aktName);
                    }
                    paramRef->height = result;
                    break;
                }
                case AKTAttributeItemType_CenterX:
                {
                    paramRef->centerX = result;
                    break;
                }
                case AKTAttributeItemType_CenterY:
                {
                    paramRef->centerY = result;
                    break;
                }
                case AKTAttributeItemType_CenterXY:
                {
                    paramRef->centerY = paramRef->centerX = result;
                    break;
                }
                default:
                    break;
            }
        }
    }
}

/*
 * Rect generated by infor in param
 */
CGRect calculateRect(AKTLayoutParamRef paramRef, AKTLayoutAttributeRef attributeRef) {
    CGRect rect;
    // The following are calculation methods
    // whether whRatio is available
    if (paramRef->whRatio<FLT_MAX) {
        rect = rectWhRatio(paramRef, attributeRef);
    }else{
        rect = rectNoWhRatio(paramRef, attributeRef);
    }
    return rect;
}

/*
 * According to param, calculate the size of frame in horizontal direction. When you call the method, please ensure there were no redundant configurations in param.
 * In one direction two configurations in addition to "whRatio" is enough to calculate the frame in that direction. WhRation will be convert to the configuration of width or height
 * @oRect : The frame of the view which will be layout according to the reference view was got before layout
 */
CGRect horizontalCalculation(AKTLayoutParamRef paramRef, CGRect oRect) {
    CGFloat x, y, width, height;
    x = oRect.origin.x;
    y = oRect.origin.y;
    width = oRect.size.width;
    height = oRect.size.height;
    if (paramRef->centerX<FLT_MAX) {
        if (paramRef->left<FLT_MAX) {
            x = paramRef->left;
            width = (paramRef->centerX-x)*2;
        }else if (paramRef->right<FLT_MAX) {
            x = paramRef->centerX-(paramRef->right-paramRef->centerX);
            width = (paramRef->right-paramRef->centerX)*2;
        }else if (paramRef->width<FLT_MAX) {
            x = paramRef->centerX-paramRef->width/2;
            width = paramRef->width;
        }else if (paramRef->centerX<FLT_MAX) {
            x = paramRef->centerX-width/2;
        }
    }else{
        if (paramRef->left<FLT_MAX) {
            x = paramRef->left;
            if (paramRef->width<FLT_MAX) {
                width = paramRef->width;
            }
            if (paramRef->right<FLT_MAX) {
                width = paramRef->right - x;
            }
        }else{
            if (paramRef->width<FLT_MAX) {
                width = paramRef->width;
            }
            if (paramRef->right<FLT_MAX) {
                x = paramRef->right-width;
            }
        }
    }
    return  CGRectMake(x, y, width, height);
}

/*
 * According to param, calculate the size of frame in vertical direction. When you call the method, please ensure there were no redundant configurations in param.
 * In one direction two configurations in addition to "whRatio" is enough to calculate the frame in that direction. WhRation will be convert to the configuration of width or height
 * @oRect : The frame of the view which will be layout according to the reference view was got before layout
 */
CGRect verticalCalculation(AKTLayoutParamRef paramRef, CGRect oRect) {
    CGFloat x, y, width, height;
    x = oRect.origin.x;
    y = oRect.origin.y;
    width = oRect.size.width;
    height = oRect.size.height;
    if (paramRef->centerY<FLT_MAX) {
        if (paramRef->top<FLT_MAX) {
            y = paramRef->top;
            height = (paramRef->centerY-y)*2;
        }else if (paramRef->bottom<FLT_MAX) {
            y = paramRef->centerY-(paramRef->bottom-paramRef->centerY);
            height = (paramRef->bottom-paramRef->centerY)*2;
        }else if (paramRef->height<FLT_MAX) {
            y = paramRef->centerY-paramRef->height/2;
            height = paramRef->height;
        }else if (paramRef->centerY<FLT_MAX) {
            y = paramRef->centerY-height/2;
        }
    }else{
        if (paramRef->top<FLT_MAX) {
            y = paramRef->top;
            if (paramRef->height<FLT_MAX) {
                height = paramRef->height;
            }
            if (paramRef->bottom<FLT_MAX) {
                height = paramRef->bottom - y;
            }
        }else{
            if (paramRef->height<FLT_MAX) {
                height = paramRef->height;
            }
            if (paramRef->bottom<FLT_MAX) {
                y = paramRef->bottom-height;
            }
        }
    }
    return  CGRectMake(x, y, width, height);
}

/*
 * The param has no configuration for whRatio, return the rect
 */
CGRect rectNoWhRatio(AKTLayoutParamRef paramRef, AKTLayoutAttributeRef attributeRef) {
    UIView *bindView = (__bridge UIView *)(attributeRef->bindView);
    CGRect rect = bindView.frame;
    // Block for checking and removing redundant configurations in horizontal direction
    int (^CheckConfigurationInNoRatio_Horizontal)() = ^int(){
        int hCount = 0;
        if (paramRef->left<FLT_MAX) {
            hCount++;
        }
        if (paramRef->right<FLT_MAX) {
            hCount++;
            if (hCount>2) {
                paramRef->right = FLT_MAX;
                hCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: right", bindView.aktName);
            }
        }
        if (paramRef->width<FLT_MAX) {
            hCount++;
            bindView.adaptiveWidth = @NO;
            if (hCount>2) {
                paramRef->width = FLT_MAX;
                hCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: width", bindView.aktName);
            }
        }
        if (paramRef->centerX<FLT_MAX) {
            hCount++;
            if (hCount>2) {
                paramRef->centerX = FLT_MAX;
                hCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: centerX", bindView.aktName);
            }
        }
        return hCount;
    };
    // Block for checking and removing redundant configurations in vertical direction
    int (^CheckConfigurationInNoRatio_Vertical)() = ^int(){
        int vCount = 0;
        if (paramRef->top<FLT_MAX) {
            vCount++;
        }
        if (paramRef->bottom<FLT_MAX) {
            vCount++;
            if (vCount>2) {
                paramRef->bottom = FLT_MAX;
                vCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: bottom", bindView.aktName);
            }
        }
        if (paramRef->height<FLT_MAX) {
            vCount++;
            bindView.adaptiveHeight = @NO;
            if (vCount>2) {
                paramRef->height = FLT_MAX;
                vCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: height", bindView.aktName);
            }
        }
        if (paramRef->centerY<FLT_MAX) {
            vCount++;
            if (vCount>2) {
                paramRef->centerY = FLT_MAX;
                vCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: centerY", bindView.aktName);
            }
        }
        return vCount;
    };
    // Calculate the size of the frame in the horizontal & vertical direction, specially centerX & centerY get priority to meet
    // Check redundant configuration, if found report it
    // Redundant configurations will be abandoned after perform the following operations, otherwise a lack of configurations
    int horizonCount = CheckConfigurationInNoRatio_Horizontal();
    // Set view's height adaptive
    if (horizonCount == 2) {
        bindView.adaptiveWidth = @NO;
    }
    rect = horizontalCalculation(paramRef, rect);
    int verticalCount = CheckConfigurationInNoRatio_Vertical();
    // Set view's width adaptive
    if (verticalCount == 2) {
        bindView.adaptiveHeight = @NO;
    }
    rect = verticalCalculation(paramRef, rect);
    return rect;
}

/*
 * The param has the configuration for whRatio, return the rect
 */
CGRect rectWhRatio(AKTLayoutParamRef paramRef, AKTLayoutAttributeRef attributeRef) {
    UIView *bindView = (__bridge UIView *)(attributeRef->bindView);
    __block CGRect rect = bindView.frame;
    // Block for checking and removing redundant configurations in horizontal direction
    int (^CheckConfigurationInRatio_Horizontal)() = ^int(){
        int hCount = 0;
        if (paramRef->left<FLT_MAX) {
            hCount++;
        }
        if (paramRef->right<FLT_MAX) {
            hCount++;
            if (hCount>2) {
                paramRef->right = FLT_MAX;
                hCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: right", bindView.aktName);
            }
        }
        if (paramRef->width<FLT_MAX) {
            hCount++;
            bindView.adaptiveWidth = @NO;
            if (hCount>2) {
                paramRef->width = FLT_MAX;
                hCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: width", bindView.aktName);
            }
        }
        if (paramRef->centerX<FLT_MAX) {
            hCount++;
            if (hCount>2) {
                paramRef->centerX = FLT_MAX;
                hCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: centerX", bindView.aktName);
            }
        }
        return hCount;
    };
    // Block for checking and removing redundant configurations in vertical direction
    int (^CheckConfigurationInRatio_Vertical)() = ^int(){
        int vCount = 0;
        if (paramRef->top<FLT_MAX) {
            vCount++;
        }
        if (paramRef->bottom<FLT_MAX) {
            vCount++;
            if (vCount>2) {
                paramRef->bottom = FLT_MAX;
                vCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: bottom", bindView.aktName);
            }
        }
        if (paramRef->height<FLT_MAX) {
            vCount++;
            bindView.adaptiveHeight = @NO;
            if (vCount>2) {
                paramRef->height = FLT_MAX;
                vCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: height", bindView.aktName);
            }
        }
        if (paramRef->centerY<FLT_MAX) {
            vCount++;
            if (vCount>2) {
                paramRef->centerY = FLT_MAX;
                vCount--;
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: centerY", bindView.aktName);
            }
        }
        return vCount;
    };
    // The result of vertical and horizontal checking, count == 2 means that the configurations were enough,
    // count < 2 means less configuration
    int hCount = 0, vCount = 0;
    hCount = CheckConfigurationInRatio_Horizontal();
    vCount = CheckConfigurationInRatio_Vertical();
    void (^CalculateSum0)() = ^() {
        paramRef->height = rect.size.width/paramRef->whRatio;
        rect = verticalCalculation(paramRef, rect);
    };
    void (^CalculateSum1)() = ^() {
        if (hCount == 1) {
            rect = horizontalCalculation(paramRef, rect);
            paramRef->height = rect.size.width/paramRef->whRatio;
            rect = verticalCalculation(paramRef, rect);
        }else{
            rect = verticalCalculation(paramRef, rect);
            paramRef->width = rect.size.height*paramRef->whRatio;
            rect = horizontalCalculation(paramRef, rect);
        }
    };
    void (^CalculateSum2)() = ^() {
        if (hCount == 0) {
            rect = verticalCalculation(paramRef, rect);
            // vCount = 2, hCount = 0 and whRatio is existing means that the view's width and height can't be adaptive.
            bindView.adaptiveWidth = bindView.adaptiveHeight = @NO;
            paramRef->width = rect.size.height*paramRef->whRatio;
            rect = horizontalCalculation(paramRef, rect);
        }else if (hCount == 1) {
            rect = horizontalCalculation(paramRef, rect);
            if (paramRef->height<FLT_MAX) {
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: whRatio", bindView.aktName);
            }else{
                paramRef->height = rect.size.width/paramRef->whRatio;
            }
            rect = verticalCalculation(paramRef, rect);
        }else if (hCount == 2) {
            rect = horizontalCalculation(paramRef, rect);
            // vCount = 0, hCount = 2 and whRatio is existing means that the view's width and height can't be adaptive.
            bindView.adaptiveWidth = bindView.adaptiveHeight = @NO;
            paramRef->height = rect.size.width/paramRef->whRatio;
            rect = verticalCalculation(paramRef, rect);
        }
    };
    void (^CalculateSum3)() = ^() {
        // vCount + hCount = 3 and whRatio is existing means that the view's width and height can't be adaptive.
        bindView.adaptiveWidth = bindView.adaptiveHeight = @NO;
        if (hCount == 1) {
            rect = verticalCalculation(paramRef, rect);
            if (paramRef->width<FLT_MAX) {
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: whRatio", bindView.aktName);
            }else{
                paramRef->width = rect.size.height*paramRef->whRatio;
            }
            rect = horizontalCalculation(paramRef, rect);
        }else if (hCount == 2) {
            rect = horizontalCalculation(paramRef, rect);
            if (paramRef->height<FLT_MAX) {
                mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: whRatio", bindView.aktName);
            }else{
                paramRef->height = rect.size.width/paramRef->whRatio;
            }
            rect = verticalCalculation(paramRef, rect);
        }
    };
    void (^CalculateSum4)() = ^() {
        // vCount + hCount = 4 and whRatio is existing means that the view's width and height can't be adaptive.
        bindView.adaptiveWidth = bindView.adaptiveHeight = @NO;
        rect = horizontalCalculation(paramRef, rect);
        rect = verticalCalculation(paramRef, rect);
        int currentRatio = rect.size.width/rect.size.height;
        int whRatio = paramRef->whRatio;
        if (!mAKT_EQ(currentRatio, whRatio)) {
            mAKT_Log(@"AKTLayoutReporter:%@ has redundant configuration: whRatio", bindView.aktName);
        }
    };
    switch (hCount+vCount) {
        case 0:// vertical & horizontal had no configuration
        {
            CalculateSum0();
            break;
        }
        case 1:// vertical or horizontal had one configuration
        {
            CalculateSum1();
            break;
        }
        case 2:// vertical & horizontal will be 1+1 or 0+2 or 2+0
        {
            CalculateSum2();
            break;
        }
        case 3:// vertical & horizontal will be 1+2 or 2+1
        {
            CalculateSum3();
            break;
        }
        case 4:// vertical & horizontal will be 2+2
        {
            CalculateSum4();
            break;
        }
        default:
            break;
    }
    return rect;
}
