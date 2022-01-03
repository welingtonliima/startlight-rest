package io.wjangoo.starlight.services.person;

import java.util.List;

import org.springframework.stereotype.Service;

import io.wjangoo.starlight.domain.person.entity.Person;
import io.wjangoo.starlight.domain.person.repository.PersonRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PersonService {
    
    private final PersonRepository personRepository;

    public List<Person> findAll() {
        return personRepository.findAll();
    }
}
