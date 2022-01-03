package io.wjangoo.starlight.domain.person.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import io.wjangoo.starlight.domain.person.entity.Person;

public interface PersonRepository extends JpaRepository<Person, Long> {

}
