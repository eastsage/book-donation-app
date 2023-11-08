package com.bookdone.book.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bookdone.book.entity.Likes;

public interface LikesRepository extends JpaRepository<Likes, Long> {
	List<Likes> findByMemberId(Long memberId);
	Optional<Likes> findByMemberIdAndBookIsbnAndLocalCode(long memberId, String isbn, int localCode);
}