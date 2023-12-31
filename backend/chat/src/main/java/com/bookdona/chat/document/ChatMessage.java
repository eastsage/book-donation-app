package com.bookdona.chat.document;

import java.time.LocalDateTime;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "chatMessage")
@ToString
public class ChatMessage {

	@Id
	private ObjectId id;
	private Long tradeId;
	private String senderNickname;
	private String message;
	@CreatedDate
	private LocalDateTime createdAt;
}
