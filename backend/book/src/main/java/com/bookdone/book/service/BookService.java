package com.bookdone.book.service;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bookdone.book.dto.BookDto;
import com.bookdone.book.dto.BookTitleUrlDto;
import com.bookdone.book.entity.Book;
import com.bookdone.book.repository.BookRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BookService {

	private final BookRepository bookRepository;

	@Transactional
	public void addTitleImage(List<BookTitleUrlDto> bookTitleUrlDtoList) {
		for (BookTitleUrlDto dto : bookTitleUrlDtoList) {
			bookRepository.updateTitleUrlByIsbn(dto.getIsbn(), dto.getTitleUrl());
		}
	}

	public List<Book> searchBookList(String title) {
		return bookRepository.findByTitleContaining(title);
	}

	public BookDto getBookDetail(String isbn) {
		return bookRepository.findByIsbn(isbn)
			.map(Book::toDto)
			.orElseThrow(() -> new IllegalArgumentException("책을 찾을 수 없습니다"));
	}

	public Map<String, BookDto> getBooksDetailMap(List<String> isbnList) {
		return bookRepository.findByIsbnIn(isbnList)
			.stream()
			.collect(Collectors.toMap(
				Book::getIsbn, // ISBN을 키로 사용
				Book::toDto    // Book 객체를 BookDto로 변환하는 함수를 값으로 사용
			));
	}

	@Transactional
	public Map<String, BookDto> getBooksDetailMap2(List<String> isbnList) {
		Map<String, BookDto> booksMap = new HashMap<>();
		for (String isbn : isbnList) {
			bookRepository.findByIsbn(isbn)
				.ifPresent(book -> booksMap.put(isbn, book.toDto()));
		}
		return booksMap;
	}
}