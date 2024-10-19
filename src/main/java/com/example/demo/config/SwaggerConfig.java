package com.example.demo.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * @author rcarcamo
 */
@Configuration
public class SwaggerConfig {

	@Bean
	public OpenAPI springOpenAPI() {
		return new OpenAPI().info(getApiInfo());
	}

	private Info getApiInfo() {
		return new Info()
			.title("Servicios para demo Argo CD")
			.version("1.0.0")
			.termsOfService("https://conexia.com/terms")
			.contact(new Contact().name("conexia").url("https://conexia.com").email("orion@conexia.com"))
			.license(new License().name("LICENSE").url("https://conexia.com/license")
			);
	}

}
