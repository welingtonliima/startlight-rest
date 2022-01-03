package io.wjangoo.starlight.drivers.http.controller.person;

import java.util.List;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.wjangoo.starlight.domain.person.entity.Person;
import io.wjangoo.starlight.services.person.PersonService;
import lombok.RequiredArgsConstructor;

@RequestMapping("/person")
@RestController
@RequiredArgsConstructor
public class PersonController {
    
    private final PersonService personService;

    @RequestMapping("/all")
    public List<Person> findAll() {
        return personService.findAll();
    }
}
