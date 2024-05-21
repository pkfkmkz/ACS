/**
 * 
 */
package alma.hibernate.test;

import java.util.Map;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.MapKeyColumn;

/**
 * @author msekoranja
 *
 */
@Entity
@Table(name="test_entity_table")
public class TestEntity {

	private Integer id;
	private Map<String, SubEntity> MAP_;
	
	@Id
	@GeneratedValue
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	/**
	 * @return the _
	 */
	
	@OneToMany(mappedBy="parentId",fetch=FetchType.EAGER)
	@MapKeyColumn(name="name")
	public Map<String, SubEntity> getMAP_() {
		return MAP_;
	}

	/**
	 * @param _ the _ to set
	 */
	public void setMAP_(Map<String, SubEntity> MAP_) {
		this.MAP_ = MAP_;
	}

}
