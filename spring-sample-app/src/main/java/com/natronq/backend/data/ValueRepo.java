package com.natronq.backend.data;

import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface ValueRepo extends CrudRepository<ValueEntity, Long> {
    Optional<ValueEntity> findOptionalByValue(String value);
}
