package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
class HelloController {

    @GetMapping("/")
    public String hello() {
        log.info("RAMA MAIN");
        return "¡Hola Spring Boot con Argo CD Main!";
    }
}
