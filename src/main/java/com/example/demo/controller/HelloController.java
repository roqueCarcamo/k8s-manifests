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

    @GetMapping("/holaArgoCD")
    public String hola() {
        log.info("RAMA MAIN");
        return "¡Hola Spring Boot con Argo CD MAIN!";
    }

    @GetMapping("/nuevo")
    public String mensaje() {
        log.info("NUEVO SERVICIO");
        return "¡Spring Boot con Argo CD!";
    }
}
