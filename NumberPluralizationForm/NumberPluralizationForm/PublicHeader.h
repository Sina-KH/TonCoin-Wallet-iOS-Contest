//
//  PublicHeader.h
//  NumberPluralizationForm
//
//  Created by Sina on 4/13/23.
//

#ifndef PublicHeader_h
#define PublicHeader_h


#endif /* PublicHeader_h */

#import <Foundation/Foundation.h>

typedef NS_ENUM(int32_t, NumberPluralizationForm) {
    NumberPluralizationFormZero,
    NumberPluralizationFormOne,
    NumberPluralizationFormTwo,
    NumberPluralizationFormFew,
    NumberPluralizationFormMany,
    NumberPluralizationFormOther
};

NumberPluralizationForm numberPluralizationForm(unsigned int lc, int n);
