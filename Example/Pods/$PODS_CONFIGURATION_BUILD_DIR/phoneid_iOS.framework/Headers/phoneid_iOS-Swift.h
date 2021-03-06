// Generated by Apple Swift version 2.3 (swiftlang-800.10.12 clang-800.0.38)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if defined(__has_feature) && __has_feature(modules)
@import ObjectiveC;
@import UIKit;
@import CoreGraphics;
@import Foundation;
@import SystemConfiguration;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class UIColor;

SWIFT_CLASS("_TtC11phoneid_iOS11ColorScheme")
@interface ColorScheme : NSObject
@property (nonatomic, strong) UIColor * _Nonnull mainAccent;
@property (nonatomic, strong) UIColor * _Nonnull extraAccent;
@property (nonatomic, strong) UIColor * _Nonnull lightText;
@property (nonatomic, strong) UIColor * _Nonnull darkText;
@property (nonatomic, strong) UIColor * _Nonnull disabledText;
@property (nonatomic, strong) UIColor * _Nonnull inputBackground;
@property (nonatomic, strong) UIColor * _Nonnull diabledBackground;
@property (nonatomic, strong) UIColor * _Nonnull activityIndicator;
@property (nonatomic, strong) UIColor * _Nonnull success;
@property (nonatomic, strong) UIColor * _Nonnull fail;
@property (nonatomic, strong) UIColor * _Null_unspecified activityIndicatorInitial;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonSeparator;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonDisabledBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonNormalBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonHighlightedBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonDisabledImage;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonNormalImage;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonHighlightedImage;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonDisabledText;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonNormalText;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonHighlightedText;
@property (nonatomic, strong) UIColor * _Null_unspecified mainViewBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified labelTopNoteText;
@property (nonatomic, strong) UIColor * _Null_unspecified labelMidNoteText;
@property (nonatomic, strong) UIColor * _Null_unspecified labelBottomNoteText;
@property (nonatomic, strong) UIColor * _Null_unspecified labelBottomNoteLinkText;
@property (nonatomic, strong) UIColor * _Null_unspecified headerBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified headerTitleText;
@property (nonatomic, strong) UIColor * _Null_unspecified headerButtonText;
@property (nonatomic, strong) UIColor * _Null_unspecified activityIndicatorNumber;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonOKNormalText;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonOKHighlightedText;
@property (nonatomic, strong) UIColor * _Null_unspecified buttonOKDisabledText;
@property (nonatomic, strong) UIColor * _Null_unspecified inputPrefixText;
@property (nonatomic, strong) UIColor * _Null_unspecified inputNumberText;
@property (nonatomic, strong) UIColor * _Null_unspecified inputNumberPlaceholderText;
@property (nonatomic, strong) UIColor * _Null_unspecified inputNumberBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified activityIndicatorCode;
@property (nonatomic, strong) UIColor * _Null_unspecified inputCodeBackbuttonNormal;
@property (nonatomic, strong) UIColor * _Null_unspecified inputCodeBackbuttonDisabled;
@property (nonatomic, strong) UIColor * _Null_unspecified inputCodePlaceholder;
@property (nonatomic, strong) UIColor * _Null_unspecified inputCodeText;
@property (nonatomic, strong) UIColor * _Null_unspecified inputCodeBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified inputCodeFailIcon;
@property (nonatomic, strong) UIColor * _Null_unspecified inputCodeSuccessIcon;
@property (nonatomic, strong) UIColor * _Null_unspecified labelPrefixText;
@property (nonatomic, strong) UIColor * _Null_unspecified labelCountryNameText;
@property (nonatomic, strong) UIColor * _Null_unspecified labelPrefixBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified sectionIndexText;
@property (nonatomic, strong) UIColor * _Null_unspecified profileCommentSectionText;
@property (nonatomic, strong) UIColor * _Null_unspecified profileCommentSectionBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified profileDataSectionTitleText;
@property (nonatomic, strong) UIColor * _Null_unspecified profileDataSectionValueText;
@property (nonatomic, strong) UIColor * _Null_unspecified profileDataSectionBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified profilePictureSectionBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified profilePictureBackground;
@property (nonatomic, strong) UIColor * _Null_unspecified profileTopUsernameText;
@property (nonatomic, strong) UIColor * _Null_unspecified profilePictureEditingHintText;
@property (nonatomic, strong) UIColor * _Null_unspecified profileActivityIndicator;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (void)applyCommonColors;
@end


@interface ColorScheme (SWIFT_EXTENSION(phoneid_iOS))
- (NSString * _Nonnull)replaceNamedColors:(NSString * _Nonnull)input;
@end

@class NumberInfo;
@class NSBundle;
@class NSCoder;

SWIFT_CLASS("_TtC11phoneid_iOS15PhoneIdBaseView")
@interface PhoneIdBaseView : UIView
@property (nonatomic, strong) NumberInfo * _Null_unspecified phoneIdModel;
@property (nonatomic, strong) ColorScheme * _Null_unspecified colorScheme;
@property (nonatomic, strong) NSBundle * _Null_unspecified localizationBundle;
@property (nonatomic, copy) NSString * _Null_unspecified localizationTableName;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC11phoneid_iOS25CompactPhoneIdLoginButton")
@interface CompactPhoneIdLoginButton : PhoneIdBaseView
@property (nonatomic, copy) NSString * _Null_unspecified phoneNumberE164;
@property (nonatomic, copy) NSString * _Nullable titleText;
@property (nonatomic, copy) NSString * _Nullable placeholderText;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)prepareForInterfaceBuilder;
- (CGSize)intrinsicContentSize;
@end

@class LoginViewController;
@class CountryCodePickerViewController;
@class UserInfo;
@class EditProfileViewController;
@class UIImage;
@class ImageEditViewController;
@class UserNameViewController;
@class LoginView;
@class CountryCodePickerView;
@class EditProfileView;
@class UserNameView;

SWIFT_PROTOCOL("_TtP11phoneid_iOS16ComponentFactory_")
@protocol ComponentFactory <NSObject>
- (LoginViewController * _Nonnull)loginViewController;
- (CountryCodePickerViewController * _Nonnull)countryCodePickerViewController:(NumberInfo * _Nonnull)model;
- (EditProfileViewController * _Nonnull)editProfileViewController:(UserInfo * _Nonnull)model;
- (ImageEditViewController * _Nonnull)imageEditViewController:(UIImage * _Nonnull)image;
- (UserNameViewController * _Nonnull)editUserNameViewController:(UserInfo * _Nonnull)model;
- (LoginView * _Nonnull)loginView:(NumberInfo * _Nonnull)model;
- (CountryCodePickerView * _Nonnull)countryCodePickerView:(NumberInfo * _Nonnull)model;
- (EditProfileView * _Nonnull)editProfileView:(UserInfo * _Nonnull)model;
- (UserNameView * _Nonnull)userNameView:(NSString * _Nullable)model;
@property (nonatomic, strong) ColorScheme * _Nonnull colorScheme;
@property (nonatomic, strong) NSBundle * _Nonnull localizationBundle;
@property (nonatomic, copy) NSString * _Nonnull localizationTableName;
@property (nonatomic, strong) UIImage * _Nullable defaultBackgroundImage;
@end


SWIFT_CLASS("_TtC11phoneid_iOS25PhoneIdBaseFullscreenView")
@interface PhoneIdBaseFullscreenView : PhoneIdBaseView
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class UITableView;
@class NSIndexPath;
@class UITableViewCell;
@class UISearchController;

SWIFT_CLASS("_TtC11phoneid_iOS21CountryCodePickerView")
@interface CountryCodePickerView : PhoneIdBaseFullscreenView <UIScrollViewDelegate, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource>
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (NSInteger)numberOfSectionsInTableView:(UITableView * _Nonnull)tableView;
- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInSection:(NSInteger)section;
- (void)tableView:(UITableView * _Nonnull)tableView didSelectRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSString * _Nullable)tableView:(UITableView * _Nonnull)tableView titleForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView * _Nonnull)tableView heightForHeaderInSection:(NSInteger)section;
- (NSArray<NSString *> * _Nullable)sectionIndexTitlesForTableView:(UITableView * _Nonnull)tableView;
- (NSInteger)tableView:(UITableView * _Nonnull)tableView sectionForSectionIndexTitle:(NSString * _Nonnull)title atIndex:(NSInteger)index;
- (void)updateSearchResultsForSearchController:(UISearchController * _Nonnull)searchController;
@end


SWIFT_CLASS("_TtC11phoneid_iOS31CountryCodePickerViewController")
@interface CountryCodePickerViewController : UIViewController
@property (nonatomic, strong) NumberInfo * _Null_unspecified phoneIdModel;
@property (nonatomic, copy) void (^ _Nullable countryCodePickerCompletionBlock)(NumberInfo * _Nonnull model);
- (nonnull instancetype)initWithModel:(NumberInfo * _Nonnull)model OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)loadView;
- (void)viewDidAppear:(BOOL)animated;
@end


SWIFT_CLASS("_TtC11phoneid_iOS23DefaultComponentFactory")
@interface DefaultComponentFactory : NSObject <ComponentFactory>
- (LoginViewController * _Nonnull)loginViewController;
- (LoginView * _Nonnull)loginView:(NumberInfo * _Nonnull)model;
- (CountryCodePickerViewController * _Nonnull)countryCodePickerViewController:(NumberInfo * _Nonnull)model;
- (CountryCodePickerView * _Nonnull)countryCodePickerView:(NumberInfo * _Nonnull)model;
- (EditProfileViewController * _Nonnull)editProfileViewController:(UserInfo * _Nonnull)model;
- (ImageEditViewController * _Nonnull)imageEditViewController:(UIImage * _Nonnull)image;
- (UserNameViewController * _Nonnull)editUserNameViewController:(UserInfo * _Nonnull)model;
- (UserNameView * _Nonnull)userNameView:(NSString * _Nullable)model;
- (EditProfileView * _Nonnull)editProfileView:(UserInfo * _Nonnull)model;
@property (nonatomic, strong) ColorScheme * _Nonnull colorScheme;
@property (nonatomic, strong) NSBundle * _Nonnull localizationBundle;
@property (nonatomic, copy) NSString * _Nonnull localizationTableName;
@property (nonatomic, strong) UIImage * _Nullable defaultBackgroundImage;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC11phoneid_iOS15EditProfileView")
@interface EditProfileView : PhoneIdBaseFullscreenView <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UserInfo * _Null_unspecified userInfo;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
@property (nonatomic, strong) UIImage * _Nullable avatarImage;
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)layoutSubviews;
- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (CGFloat)tableView:(UITableView * _Nonnull)tableView heightForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)tableView:(UITableView * _Nonnull)tableView didSelectRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (NSString * _Nullable)tableView:(UITableView * _Nonnull)tableView titleForFooterInSection:(NSInteger)section;
- (UIView * _Nullable)tableView:(UITableView * _Nonnull)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView * _Nonnull)tableView heightForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView * _Nonnull)tableView heightForHeaderInSection:(NSInteger)section;
@end

@class UIImagePickerController;

SWIFT_CLASS("_TtC11phoneid_iOS25EditProfileViewController")
@interface EditProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UserInfo * _Null_unspecified user;
- (nonnull instancetype)initWithModel:(UserInfo * _Nonnull)model OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)loadView;
- (void)didReceiveMemoryWarning;
- (void)imagePickerController:(UIImagePickerController * _Nonnull)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> * _Nonnull)info;
@end


SWIFT_CLASS("_TtC11phoneid_iOS23ImageEditViewController")
@interface ImageEditViewController : UIViewController
@property (nonatomic, readonly, strong) ColorScheme * _Null_unspecified colorScheme;
@property (nonatomic, readonly, strong) NSBundle * _Null_unspecified localizationBundle;
@property (nonatomic, readonly, copy) NSString * _Null_unspecified localizationTableName;
- (nonnull instancetype)initWithImage:(UIImage * _Nonnull)image OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)loadView;
- (void)viewDidLoad;
- (void)viewDidLayoutSubviews;
- (void)viewWillAppear:(BOOL)animated;
@end


SWIFT_CLASS("_TtC11phoneid_iOS15KeychainStorage")
@interface KeychainStorage : NSObject
+ (void)saveValue:(NSString * _Nonnull)value;
+ (NSString * _Nullable)loadValue;
+ (BOOL)saveValue:(NSString * _Nonnull)key value:(NSString * _Nonnull)value;
+ (NSString * _Nullable)loadValue:(NSString * _Nonnull)key;
+ (BOOL)saveIntValue:(NSString * _Nonnull)key value:(NSInteger)value;
+ (BOOL)saveTimeIntervalValue:(NSString * _Nonnull)key value:(NSTimeInterval)value;
+ (BOOL)deleteValue:(NSString * _Nonnull)key;
+ (BOOL)clear;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC11phoneid_iOS9LoginView")
@interface LoginView : PhoneIdBaseFullscreenView
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (BOOL)resignFirstResponder;
@end


SWIFT_CLASS("_TtC11phoneid_iOS19LoginViewController")
@interface LoginViewController : UIViewController
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)loadView;
- (void)numberInputCompleted:(NumberInfo * _Nonnull)model;
- (void)goBack;
- (void)verifyCode:(NumberInfo * _Nonnull)model code:(NSString * _Nonnull)code;
- (void)close;
@end


@interface NSBundle (SWIFT_EXTENSION(phoneid_iOS))
@end


@interface NSMutableData (SWIFT_EXTENSION(phoneid_iOS))
@end


@interface NSURLRequest (SWIFT_EXTENSION(phoneid_iOS))
@end


SWIFT_CLASS("_TtC11phoneid_iOS10NumberInfo")
@interface NumberInfo : NSObject
@property (nonatomic, copy) NSString * _Nullable phoneNumber;
@property (nonatomic, copy) NSString * _Nullable phoneCountryCode;
@property (nonatomic, copy) NSString * _Nullable isoCountryCode;
@property (nonatomic, readonly, copy) NSString * _Nonnull defaultCountryCode;
@property (nonatomic, readonly, copy) NSString * _Nonnull defaultIsoCountryCode;
@property (nonatomic, readonly, copy) NSString * _Nullable phoneCountryCodeSim;
@property (nonatomic, readonly, copy) NSString * _Nullable isoCountryCodeSim;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithNumber:(NSString * _Nonnull)number countryCode:(NSString * _Nonnull)countryCode isoCountryCode:(NSString * _Nonnull)isoCountryCode;
- (nonnull instancetype)initWithNumberE164:(NSString * _Nullable)numberE164;
- (NSString * _Nullable)e164Format;
@property (nonatomic, readonly, copy) NSString * _Nonnull description;
@end

@class NSDictionary;

SWIFT_CLASS("_TtC11phoneid_iOS14ParseableModel")
@interface ParseableModel : NSObject
- (nonnull instancetype)initWithJson:(NSDictionary * _Nonnull)json OBJC_DESIGNATED_INITIALIZER;
- (BOOL)isValid;
@end



@class UIImageView;
@class UILabel;
@class UIActivityIndicatorView;

SWIFT_CLASS("_TtC11phoneid_iOS18PhoneIdLoginButton")
@interface PhoneIdLoginButton : UIControl
@property (nonatomic, strong) ColorScheme * _Null_unspecified colorScheme;
@property (nonatomic, strong) NSBundle * _Null_unspecified localizationBundle;
@property (nonatomic, copy) NSString * _Null_unspecified localizationTableName;
@property (nonatomic, copy) NSString * _Null_unspecified phoneNumberE164;
@property (nonatomic, readonly, strong) UIImageView * _Nonnull imageView;
@property (nonatomic, readonly, strong) UILabel * _Nonnull titleLabel;
@property (nonatomic, readonly, strong) UIView * _Nonnull separatorView;
@property (nonatomic, readonly, strong) UIActivityIndicatorView * _Nonnull activityIndicator;
- (void)setTitleColor:(UIColor * _Nullable)color forState:(UIControlState)state;
- (void)setImageColor:(UIColor * _Nullable)color forState:(UIControlState)state;
- (void)setBackgroundColor:(UIColor * _Nullable)color forState:(UIControlState)state;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
- (nonnull instancetype)initWithFrame:(CGRect)frame;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder;
- (void)prepareForInterfaceBuilder;
- (CGSize)intrinsicContentSize;
+ (BOOL)requiresConstraintBasedLayout;
@end

@class PhoneIdService;

SWIFT_CLASS("_TtC11phoneid_iOS27PhoneIdLoginWorkflowManager")
@interface PhoneIdLoginWorkflowManager : NSObject
@property (nonatomic, strong) ColorScheme * _Null_unspecified colorScheme;
@property (nonatomic, strong) NSBundle * _Null_unspecified localizationBundle;
@property (nonatomic, copy) NSString * _Null_unspecified localizationTableName;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithPhoneIdService:(PhoneIdService * _Nonnull)_phoneIdService phoneIdComponentFactory:(id <ComponentFactory> _Nonnull)_phoneIdComponentFactory OBJC_DESIGNATED_INITIALIZER;
- (void)startLoginFlow:(UIViewController * _Nullable)presentFromController initialPhoneNumerE164:(NSString * _Nullable)initialPhoneNumerE164 startAnimatingProgress:(void (^ _Nullable)(void))startAnimatingProgress stopAnimationProgress:(void (^ _Nullable)(void))stopAnimationProgress;
@end

@class TokenInfo;
@class NSError;

SWIFT_CLASS("_TtC11phoneid_iOS14PhoneIdService")
@interface PhoneIdService : NSObject
+ (PhoneIdService * _Nonnull)sharedInstance;
@property (nonatomic, strong) id <ComponentFactory> _Null_unspecified componentFactory;
@property (nonatomic, copy) void (^ _Nullable phoneIdAuthenticationSucceed)(TokenInfo * _Nonnull token);
@property (nonatomic, copy) void (^ _Nullable phoneIdAuthenticationCancelled)(void);
@property (nonatomic, copy) void (^ _Nullable phoneIdAuthenticationRefreshed)(TokenInfo * _Nonnull token);
@property (nonatomic, copy) void (^ _Nullable phoneIdWorkflowErrorHappened)(NSError * _Nonnull error);
@property (nonatomic, copy) void (^ _Nullable phoneIdWorkflowNumberInputCompleted)(NumberInfo * _Nonnull numberInfo);
@property (nonatomic, copy) void (^ _Nullable phoneIdWorkflowVerificationCodeInputCompleted)(NSString * _Nonnull verificationCode);
@property (nonatomic, copy) void (^ _Nullable phoneIdWorkflowCountryCodeSelected)(NSString * _Nonnull countryCode);
@property (nonatomic, copy) void (^ _Nullable phoneIdDidLogout)(void);
@property (nonatomic, readonly) BOOL isLoggedIn;
@property (nonatomic, readonly, strong) TokenInfo * _Nullable token;
@property (nonatomic, readonly, copy) NSString * _Nullable appName;
@property (nonatomic, readonly, copy) NSString * _Nullable clientId;
@property (nonatomic, readonly) BOOL autorefreshToken;
- (void)configureClient:(NSString * _Nonnull)id autorefresh:(BOOL)autorefresh;
- (void)logout;
- (void)loadMyProfile:(void (^ _Nonnull)(UserInfo * _Nullable userInfo, NSError * _Nullable error))completion;
- (void)updateUserProfile:(UserInfo * _Nonnull)userInfo completion:(void (^ _Nonnull)(NSError * _Nullable error))completion;
- (void)updateUserAvatar:(UIImage * _Nonnull)image completion:(void (^ _Nonnull)(NSError * _Nullable error))completion;
- (void)refreshToken:(void (^ _Nonnull)(TokenInfo * _Nullable token, NSError * _Nullable error))completion;
- (void)uploadContactsWithDebugMode:(BOOL)debugMode completion:(void (^ _Nonnull)(NSInteger numberOfUpdatedContacts, NSError * _Nullable error))completion;
@end


SWIFT_CLASS("_TtC11phoneid_iOS19PhoneIdServiceError")
@interface PhoneIdServiceError : NSError
- (nonnull instancetype)initWithCode:(NSInteger)code descriptionKey:(NSString * _Nonnull)descriptionKey reasonKey:(NSString * _Nullable)reasonKey OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
+ (PhoneIdServiceError * _Nonnull)inappropriateResponseError:(NSString * _Nonnull)descriptionKey reasonKey:(NSString * _Nullable)reasonKey;
+ (PhoneIdServiceError * _Nonnull)requestFailedError:(NSString * _Nonnull)descriptionKey reasonKey:(NSString * _Nullable)reasonKey;
+ (PhoneIdServiceError * _Nonnull)invalidParameters:(NSString * _Nonnull)descriptionKey reasonKey:(NSString * _Nullable)reasonKey;
@end

@class NSNotificationCenter;

SWIFT_CLASS("_TtC11phoneid_iOS12Reachability")
@interface Reachability : NSObject
@property (nonatomic, copy) void (^ _Nullable whenReachable)(Reachability * _Nonnull);
@property (nonatomic, copy) void (^ _Nullable whenUnreachable)(Reachability * _Nonnull);
@property (nonatomic) BOOL reachableOnWWAN;
@property (nonatomic, strong) NSNotificationCenter * _Nonnull notificationCenter;
@property (nonatomic, readonly, copy) NSString * _Nonnull currentReachabilityString;
- (nonnull instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef _Nonnull)reachabilityRef OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithHostname:(NSString * _Nonnull)hostname error:(NSError * _Nullable * _Null_unspecified)error;
+ (Reachability * _Nullable)reachabilityForInternetConnectionAndReturnError:(NSError * _Nullable * _Null_unspecified)error;
+ (Reachability * _Nullable)reachabilityForLocalWiFiAndReturnError:(NSError * _Nullable * _Null_unspecified)error;
- (BOOL)startNotifierAndReturnError:(NSError * _Nullable * _Null_unspecified)error;
- (void)stopNotifier;
- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;
@property (nonatomic, readonly, copy) NSString * _Nonnull description;
@end

@class NSDate;

SWIFT_CLASS("_TtC11phoneid_iOS9TokenInfo")
@interface TokenInfo : ParseableModel
@property (nonatomic, copy) NSString * _Nullable accessToken;
@property (nonatomic, copy) NSString * _Nullable refreshToken;
@property (nonatomic, strong) NSDate * _Nullable timestamp;
@property (nonatomic, readonly, strong) NumberInfo * _Nullable numberInfo;
@property (nonatomic, readonly, strong) NSDate * _Nullable expirationTime;
@property (nonatomic, readonly) BOOL expired;
- (nonnull instancetype)initWithJson:(NSDictionary * _Nonnull)json OBJC_DESIGNATED_INITIALIZER;
- (BOOL)isValid;
@end


@interface UIColor (SWIFT_EXTENSION(phoneid_iOS))
- (nonnull instancetype)initWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
- (nonnull instancetype)initWithHex:(NSInteger)hex;
- (NSString * _Nonnull)hexString;
@end


@interface UIImage (SWIFT_EXTENSION(phoneid_iOS))
@end


@interface UIStoryboard (SWIFT_EXTENSION(phoneid_iOS))
@end


SWIFT_CLASS("_TtC11phoneid_iOS8UserInfo")
@interface UserInfo : ParseableModel
@property (nonatomic, copy) NSString * _Nullable id;
@property (nonatomic, copy) NSString * _Nullable clientId;
@property (nonatomic, copy) NSString * _Nullable screenName;
@property (nonatomic, copy) NSString * _Nullable phoneNumber;
@property (nonatomic, strong) NSDate * _Nullable dateOfBirth;
@property (nonatomic, copy) NSString * _Nullable imageURL;
@property (nonatomic, strong) UIImage * _Nullable updatedImage;
- (nonnull instancetype)initWithJson:(NSDictionary * _Nonnull)json OBJC_DESIGNATED_INITIALIZER;
- (BOOL)isValid;
@end

@class UITextField;

SWIFT_CLASS("_TtC11phoneid_iOS12UserNameView")
@interface UserNameView : PhoneIdBaseFullscreenView <UITextFieldDelegate>
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (BOOL)textField:(UITextField * _Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString * _Nonnull)string;
@end


SWIFT_CLASS("_TtC11phoneid_iOS22UserNameViewController")
@interface UserNameViewController : UIViewController
@property (nonatomic, copy) void (^ _Nullable completeEditing)(UserInfo * _Nonnull model);
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)viewDidLoad;
- (void)close;
- (void)save;
@end

#pragma clang diagnostic pop
