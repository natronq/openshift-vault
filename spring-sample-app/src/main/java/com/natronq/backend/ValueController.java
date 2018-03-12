package com.natronq.backend;

import com.natronq.backend.data.ValueEntity;
import com.natronq.backend.data.ValueRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;


@RestController
public class ValueController {
    @Autowired
    private ValueRepo valueRepo;

    @org.springframework.beans.factory.annotation.Value("${password}")
	String password;

	@RequestMapping("/secret")
	public String secret() {
		return "my secret is" + password;
    }

    @RequestMapping(value = "/value", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Value> limit(@RequestBody Value input) {

        Optional<ValueEntity> entity = valueRepo.findOptionalByValue(input.getValue());
        if(!entity.isPresent()) {
            input.setRespText("Value " + input.getValue() + " not available");
            return ResponseEntity.ok(input);
        }

        input.setRespText("Success");
        return ResponseEntity.ok(input);
    }

    @RequestMapping(value = "/addValue", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity addValue(@RequestBody Value input) {
        Optional<ValueEntity> entity = valueRepo.findOptionalByValue(input.getValue());
        if(entity.isPresent()) {
            return ResponseEntity.status(HttpStatus.ACCEPTED).build();
        }
        ValueEntity newEntity = new ValueEntity();
        newEntity.setValue(input.getValue());
        valueRepo.save(newEntity);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
}