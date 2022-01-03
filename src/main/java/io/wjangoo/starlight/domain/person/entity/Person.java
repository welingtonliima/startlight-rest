package io.wjangoo.starlight.domain.person.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;

import io.wjangoo.starlight.utils.Constants;
import lombok.Data;

@Data
@Entity
@Table(schema = Constants.DEFAULT_SCHEMA, name = "TB_PESSOA")
public class Person {
    
    @Id
    @NotNull
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID_PESSOA", nullable = false)
    private Long id;

    @NotNull
    @Column(name = "NO_PESSOA", nullable = false)
    private String name;

    @NotNull
    @Column(name = "NU_DOCUMENTO", nullable = false)
    private String document;

}
