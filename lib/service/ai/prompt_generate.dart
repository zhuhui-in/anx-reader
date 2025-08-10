import 'dart:io';
import 'package:flutter/material.dart';
import 'package:anx_reader/page/book_player/epub_player.dart';
import 'package:anx_reader/config/shared_preference_provider.dart';
import 'package:anx_reader/enums/ai_prompts.dart';

String generatePromptTest() {
  String prompt = Prefs().getAiPrompt(AiPrompts.test);
  String currentLocale = Prefs().locale?.languageCode ?? Platform.localeName;
  prompt = prompt.replaceAll('{{language_locale}}', currentLocale);
  return prompt;
}

String generatePromptSummaryTheChapter(String chapter) {
  String prompt = Prefs().getAiPrompt(AiPrompts.summaryTheChapter);
  prompt = prompt.replaceAll('{{chapter}}', chapter.trim());
  return prompt;
}

String generatePromptSummaryTheBook(String book, String author) {
  String prompt = Prefs().getAiPrompt(AiPrompts.summaryTheBook);
  prompt = prompt.replaceAll('{{book}}', book);
  prompt = prompt.replaceAll('{{author}}', author);
  return prompt;
}

String generatePromptSummaryThePreviousContent(String previousContent) {
  String prompt = Prefs().getAiPrompt(AiPrompts.summaryThePreviousContent);
  prompt = prompt.replaceAll('{{previous_content}}', previousContent.trim());
  return prompt;
}

String generatePromptTranslate(String text, String toLocale, String fromLocale) {
  String prompt = Prefs().getAiPrompt(AiPrompts.translate);
  final epubPlayerKey = GlobalKey<EpubPlayerState>();
  final previousContent = epubPlayerKey.currentState!.previousContent(1000);  
  prompt = prompt.replaceAll('{{text}}', text.trim());
  prompt = prompt.replaceAll('{{to_locale}}', toLocale);
  prompt = prompt.replaceAll('{{from_locale}}', fromLocale);
  prompt = prompt.replaceAll('{{previous_content}}', previousContent);
  return prompt;
}
