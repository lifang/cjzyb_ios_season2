//
//  Metaphone2.m
//
//  Created by sam on 2/03/10.
//

#import "Metaphone2.h"


@implementation Metaphone2

+ (NSString *)metaphone:(NSString *)aWord {
	NSString *code = @"";
	int term_length = [aWord length];
	if (term_length == 0) {
		return code;
	}
	
//	NSArray *vowels = [[NSArray alloc] initWithObjects:@"a",@"e",@"i",@"o",@"u",nil];
	
	aWord = [aWord lowercaseString];
	aWord = [aWord stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
	aWord = [aWord stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	
	if ([aWord length] == 0) {
		return code;
	}
	
//	NSString *firstChar = [aWord substringToIndex:1];
	NSString *aWord2 = [aWord substringToIndex:1];
	for (int idx = 0; idx < [aWord length]; ++idx) {
		NSString *ch = [aWord substringWithRange:NSMakeRange(idx, 1)];
		if (![ch isEqualToString:[aWord2 substringWithRange:NSMakeRange([aWord2 length]-1, 1)]]) {
			aWord2 = [aWord2 stringByAppendingString:ch];
		}
	}
	
/*	firstChar = [aWord2 substringToIndex:1];
	NSString *aWord3 = [aWord2 substringToIndex:1];
	for (int idx = 1; idx < [aWord2 length]; ++idx) {
		NSString *ch = [aWord2 substringWithRange:NSMakeRange(idx, 1)];
		if (![vowels containsObject:ch]) {
			aWord3 = [aWord3 stringByAppendingString:ch];
		}
	}*/
	
	aWord = aWord2;
	term_length = [aWord length];
	if (term_length == 0) {
		return code;
	}
	
	if (term_length > 1) {
		NSString *firstChars = [aWord substringToIndex:2];
		NSDictionary *translations = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"e",@"ae",
									  @"n",@"gn",
									  @"n",@"kn",
									  @"n",@"pn",
									  @"n",@"wr",
									  @"w",@"wh",nil];
		
		if ([translations objectForKey:firstChars] != nil) {
			aWord = [aWord substringFromIndex:2];
			code = [translations objectForKey:firstChars];
			term_length = [aWord length];
		}
	} else if ([aWord characterAtIndex:0] == 'x') {
		aWord = @"";
		code = @"s";
		term_length = 0;
	}
	
	NSDictionary *standardTranslations = [NSDictionary dictionaryWithObjectsAndKeys:
										  @"b",@"b",
										  @"k",@"c",
										  @"t",@"d",
										  @"k",@"g",
										  @"h",@"h",
										  @"k",@"k",
										  @"p",@"p",
										  @"k",@"q",
										  @"s",@"s",
										  @"t",@"t",
										  @"f",@"v",
										  @"w",@"w",
										  @"ks",@"x",
										  @"y",@"y",
										  @"s",@"z",
										  nil];
	int i = 0;
	while (i < term_length) {
		NSString *addChar=@"", *part_n_2=@"", *part_n_3=@"", *part_n_4=@"", *part_c_2=@"", *part_c_3=@"";
		if (i < (term_length - 1)) {
			part_n_2 = [aWord substringWithRange:NSMakeRange(i, 2)];
			if (i > 0) {
				part_c_2 = [aWord substringWithRange:NSMakeRange(i-1, 2)];
				part_c_3 = [aWord substringWithRange:NSMakeRange(i-1, 3)];
			}
		}
		
		if (i < (term_length - 2)) {
			part_n_3 = [aWord substringWithRange:NSMakeRange(i, 3)];
		}
		
		if (i < (term_length - 3)) {
			part_n_4 = [aWord substringWithRange:NSMakeRange(i, 4)];
		}
		
		switch ([aWord characterAtIndex:i]) {
			case 'b':
				addChar = [standardTranslations objectForKey:@"b"];
				if (i == (term_length - 1)) {
					if (i > 0) {
						if ([aWord characterAtIndex:i-1] == 'm') {
							addChar = @"";
						}
					}
				}
				break;
			case 'c':
				addChar = [standardTranslations objectForKey:@"c"];
				if ([part_c_2 isEqualToString:@"ch"]) {
					addChar = @"x";
				} else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"c[iey]"] evaluateWithObject:part_n_2] == YES) {
					addChar = @"s";
				}
				
				if ([part_n_3 isEqualToString:@"cia"]) {
					addChar = @"x";
				}
				
				if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"sc[iey]"] evaluateWithObject:part_c_3] == YES) {
					addChar = @"";
				}
				break;
			case 'd':
				addChar = [standardTranslations objectForKey:@"d"];
				if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"dg[iey]"] evaluateWithObject:part_n_3] == YES) {
					addChar = @"j";
				}
				break;
			case 'g':
				addChar = [standardTranslations objectForKey:@"g"];
				if ([part_n_2 isEqualToString:@"gh"]) {
					if (i == (term_length - 2)) {
						addChar = @"";
					}
				} else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"gh[aeiouy]"] evaluateWithObject:part_n_3] == YES) {
					addChar = @"";
				} else if ([part_n_2 isEqualToString:@"gn"]) {
					addChar = @"";
				} else if ([part_n_4 isEqualToString:@"gned"]) {
					addChar = @"";
				} else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"dg[iey]"] evaluateWithObject:part_c_3] == YES) {
					addChar = @"";
				} else if ([part_n_2 isEqualToString:@"gi"]) {
					if (![part_c_3 isEqualToString:@"ggi"]) {
						addChar = @"j";
					}
				} else if ([part_n_2 isEqualToString:@"ge"]) {
					if (![part_c_3 isEqualToString:@"gge"]) {
						addChar = @"j";
					}
				} else if ([part_n_2 isEqualToString:@"gy"]) {
					if (![part_c_3 isEqualToString:@"ggy"]) {
						addChar = @"j";
					}
				} else if ([part_n_2 isEqualToString:@"gg"]) {
					addChar = @"";
				}
				break;
			case 'h':
				addChar = [standardTranslations objectForKey:@"h"];
				if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[aeiouy]h[^aeiouy]"] evaluateWithObject:part_c_3] == YES) {
					addChar = @"";
				} else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[csptg]h"] evaluateWithObject:part_c_2] == YES) {
					addChar = @"";
				}
				break;
			case 'k':
				addChar = [standardTranslations objectForKey:@"k"];
				if ([part_c_2 isEqualToString:@"ck"]) {
					addChar = @"";
				}
				break;
			case 'p':
				addChar = [standardTranslations objectForKey:@"p"];
				if ([part_n_2 isEqualToString:@"ph"]) {
					addChar = @"f";
				}
				break;
			case 'q':
				addChar = [standardTranslations objectForKey:@"q"];
				break;
			case 's':
				addChar = [standardTranslations objectForKey:@"s"];
				if ([part_n_2 isEqualToString:@"sh"]) {
					addChar = @"x";
				}
				if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"si[ao]"] evaluateWithObject:part_n_3] == YES) {
					addChar = @"x";
				}
				break;
			case 't':
				addChar = [standardTranslations objectForKey:@"t"];
				if ([part_n_2 isEqualToString:@"th"]) {
					addChar = @"0";
				}
				if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"ti[ao]"] evaluateWithObject:part_n_3] == YES) {
					addChar = @"x";
				}
				break;
			case 'v':
				addChar = [standardTranslations objectForKey:@"v"];
				break;
			case 'w':
				addChar = [standardTranslations objectForKey:@"w"];
				if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"w[^aeiouy]"] evaluateWithObject:part_n_2] == YES) {
					addChar = @"";
				}
				break;
			case 'x':
				addChar = [standardTranslations objectForKey:@"x"];
				break;
			case 'y':
				addChar = [standardTranslations objectForKey:@"y"];
				break;
			case 'z':
				addChar = [standardTranslations objectForKey:@"z"];
				break;
            case 'a':
            case 'e':
            case 'i':
            case 'o':
            case 'u':
                if (i == 0) {
                    addChar = [aWord substringWithRange:NSMakeRange(i,1)];
                } else {
                    addChar = @"";
                }
                break;
			default:
				addChar = [aWord substringWithRange:NSMakeRange(i, 1)];
				break;
		}
		
		code = [code stringByAppendingString:addChar];
		i += 1;
	}
	
	return code;
				
}

@end
