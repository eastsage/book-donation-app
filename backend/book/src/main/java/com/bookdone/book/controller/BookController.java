package com.bookdone.book.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.bookdone.book.dto.BookDto;
import com.bookdone.book.dto.ReviewRequestDto;
import com.bookdone.book.dto.ReviewResponseDto;
import com.bookdone.book.entity.Book;
import com.bookdone.book.entity.RedisBook;
import com.bookdone.book.service.BookService;
import com.bookdone.book.service.RedisSearchService;
import com.bookdone.book.service.ReviewService;
import com.bookdone.global.response.BaseResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/books")
public class BookController {

	private final ReviewService reviewService;
	private final BookService bookService;
	private final RedisSearchService redisSearchService;

	// TODO : 책 제목 자동완성 리스트 반환 // redis 데이터 넣어줘야함
	@GetMapping("/auto-completion/{bookName}")
	public ResponseEntity<?> autoCompletionBookList(@RequestParam String query) {
		List<RedisBook> bookTitles = redisSearchService.searchAndSortByTitle(query);
		return BaseResponse.okWithData(HttpStatus.OK, "책 제목 자동완성", bookTitles);
	}

	// TODO : 엔터 쳤을 때 이동하는 곳
	@GetMapping("/search/{title}")
	public ResponseEntity<?> searchBookList(@PathVariable String title) {
		List<Book> books = bookService.searchBookList(title);
		return BaseResponse.okWithData(HttpStatus.OK, "책 리스트 조회 완료", books);
	}

	/* TODO : 책 세부 디테일
			  자동완성 클릭하면 이곳을 사용 or 책 리스트에서 클릭하면 이곳으로 옴
			  */
	@GetMapping("/detail/{isbn}")
	public ResponseEntity<?> getBookDetail(@PathVariable String isbn) {
		BookDto book = bookService.getBookDetail(isbn);
		return BaseResponse.okWithData(HttpStatus.OK, "책 상세 조회 완료", book);
	}

	// TODO : 책에 대한 리뷰 조회
	@GetMapping("/reviews/{isbn}")
	public ResponseEntity<?> getReviews(@PathVariable String isbn) {
		List<ReviewResponseDto> reviews = reviewService.getReviews(isbn);
		return BaseResponse.okWithData(HttpStatus.OK, "책에 대한 리뷰 조회", reviews);
	}

	// TODO : 책에 대한 리뷰 작성
	@PostMapping("/reviews")
	public ResponseEntity<?> postReview(@RequestBody ReviewRequestDto reviewDto){
		reviewService.postReview(reviewDto);
		return BaseResponse.ok(HttpStatus.OK, "책에 대한 리뷰 작성");
	}
}