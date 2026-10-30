# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# Changed

## [Unreleased]

## [1.0.56] - 2026-09-24
- Fixed cWebHtmlBox firing OnClick when disabled. [DF-5213]
- Fixed RemoveKeyHandler leaving empty handlers in the client array by removing them with splice. [DF-6432]
- Fixed cWebMenuButton root captions with pbAllowHtml when navigating back to the root menu. [DF-6487]
- Fixed radio focus staying on the previously selected radio after direct circle clicks. [DF-5538]
- Fixed new-record navigation state being lost when restoring a view from a state hash. [DF-6528]
- Fixed the WebAppDesigner fixed row height field showing 1 instead of the resolved pixel height for default rows. [DF-6615]
- Fixed cWebImage failing to load local files with Unicode filenames in FlexTron by decoding WebView2 resource URLs as UTF-8. [DF-6625]
- Fixed cWebSelectionForm lookups for full-name pasted searches. [DF-6636]
- Fix entering strings returning errors when used as search term in cWebSuggestionForm [DF-6632]

## [1.0.52] - 2026-08-14
- Fixed OnPostCreate issue, and made creation possible in the cWebSelectionForm.
- WebList updateRow did not properly update display because it lost its _iItemIndex.
- FlexTron sync call was being too agressive and did not wait for JavaScript operations to finish. [DF-6447]
- Updated Flat_Touch, Flat_Desktop and Material selection styling when in focus. [DF-6492]

- Implement a piTabIndex that determines tab order of controls inside of a view. [DF-4450]

## [1.0.51] - 2026-07-21
- Have the File come from the Entry_Item rather than the Main_File, because you want to find on a parent.

## [1.0.50] - 2026-07-20
- Fixed Validation table trying to find a record + updated dfo from selectionfrom to not add pbAllowCreate. [DF-6419]
- Mark cWebListFilter_Mixin as public [DF-6426]
- Fixed process pool issue with the cWebBaseSelectionForm when it updates its own properties based on the SelectionSource. [DF-6421]

## [1.0.49] - 2026-07-15
- Reverted cWebPromptList back to cWebList [DF-6409]

## [1.0.48] - 2026-07-14
- Fixed DDO re-entrant operation not allowed error in WebList. [DF-6238]
- Fixed double click being broken in lookup lists. [DF-6230]
- Fixed pbOfflineEditing=False clearing SelectionIndicator value after changing row. [DF-5354]
- Fixed cWebGrid issues by adjusting FlexTron attach improvement. [DF-6314]
- Fixed MultiSelectList to have the default weblist styling based on the pbShowSelected property. [DF-5416]
- Fixed SelectAll function and have the the SelectAll actually select all also when scrolling through the list. Updated theme to have a better selection color [DF-4894]
- Fixed pbSuggestions and pbPaged. pbSuggestions sets the SelectionForm to work as a WebSuggestionForm where you require to search for more records. pbPaged makes it have pages and adds a showmore. [DF-6344]

## [1.0.47] - 2026-06-24
- Advanced Search is now always visible. [DF-6236].
- Fixed no suggestions being shown with a static source when typing without having the suggestion list shown. [DF-6248].
- Moved cDbLocalWebControlHost to Web UI FlexTron package [DF-6315]
- FlexTron DEO's now attach and detach to their server at the same moment as windows controls [DF-5927]
- FlexTron DEO's now refresh properly during initialization without disturbing the DD state [DF-6314]
- Fixed missing bServer member on a Tag item. [DF-6334]

## [1.0.46] - 2026-06-08
- Fix grid layout not displaying properly in the designer [DF-6240]

## [1.0.45] - 2025-05-27
- Focus fixes for the selection form.

## [1.0.44] - 2026-05-20
- Improvements to the selection form.

## [1.0.43] - 2026-05-06
- Added cWebSelectionForm. Improved selection suggestions with action rows. Added multi column filtering support to cWebList. Updated cWebPromptList to use cWebMultiSelectList. [DF-5490].
- Renamed AllWebControlClasses.pkg to AllWebUIServerClasses for server and AllWebUIFlexTronClasses for FlexTron to prevent problems when using FlexTron and server in the same project [DF-6095].
- cLocalWebControlHost now falls back to the global resource manager if there is one. It is recommended to not place the resource manager in a deferred view [DF-5540].

## [1.0.42] - 2026-04-17
- Captions in webviews/dialogs are now h1 elements instead of label elements [DF-6025].
- Added pbAlwaysShowConfigureButton to cWebWidget and cWebWidgetContainer to allow showing configuration options even when the container is not in edit mode [DF-6030].
- Fix MultiSelectList not selecting the proper row when clicking the checkbox after a FindFromBottom [DF-5653].
- Marked functions private to cleanup the class reference [DF-5999].
- Fixed Flat_Touch theme refering to --warningRegular when it should have been --df-WarningRegular instead [DF-5482].
- Prevent Weblist/Webgrid from sending OnFocus to the server if pbEnabled is set to false [DF-5955].
- Avoid sending empty responses in error situations during call handling. Always try to generate a response with error messages. [DF-5939]
- Fixed WebDD_Debug.wo giving errors in problem resolution panel due to missing use statement [DF-5901].
- Add property (pbSizeToCurrentCard) for cWebCardContainer and cWebTabContainer to change height based on the currently active card/tab [DF-5907].
- Changed piDefaultRowHeight to psDefaultRowHeight so that it is more consistent with psDefaultColumnWidth [DF-5930].

## [1.0.41] - 2026-03-10

- New icons for packages.

## [1.0.40] - 2026-03-05

- Added WebListView, WebListModel, WebListFooterView, WebListController, WebListPagedModel, WebListPlaceHolderView to the javascript df namespace object [DF-5867].
- Fixed a bug in df.sys.string.copyCase which was causing issues when using mmmm within psMask with peDataType typeDate / typeDateTime [DF-5851].

## [1.0.39] - 2026-02-07

- Initial version as a package.