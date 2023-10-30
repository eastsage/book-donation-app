package com.bookdone.history.application.repository;

import com.bookdone.history.domain.History;
import com.bookdone.history.infra.entity.HistoryEntity;

import java.util.List;
import java.util.Optional;

public interface HistoryRepository {
    public Long updateHistory(History History);
    public History findById(Long id);
    public History findByDonationIdAndMemberId(Long donationId, Long memberId);

    public List<History> findAll(Long donationId);
}
