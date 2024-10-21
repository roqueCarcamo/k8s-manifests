package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
class HelloController {

    @PostConstruct
    public void init(){
        log.info("RAMA MAIN SINCRONIZADA");
    } 

    @GetMapping("/hello")
    public String hello() {
        log.info("RAMA MAIN");
        return "¡Hola Spring Boot con Argo CD Main!";
    }
}
