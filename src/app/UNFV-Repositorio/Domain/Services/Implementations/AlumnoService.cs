using Data.DTO;
using Data.Repositories;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class AlumnoService : IAlumnoService
    {
        IAlumnoRepository _alumnoRepository;
        IPersonaRepository _personaRepository;

        public AlumnoService(IAlumnoRepository alumnoRepository, IPersonaRepository personaRepository)
        {
            _alumnoRepository = alumnoRepository;
            _personaRepository = personaRepository;
        }

        public ResponseData Create(AlumnoEntity alumnoEntity)
        {
            ResponseData responsePersona;
            ResponseData responseAlumno;
            
            var persona = Mapper.AlumnoEntityToTC_Persona(alumnoEntity);

            var alumno = Mapper.AlumnoEntityToTC_Alumno(alumnoEntity);

            responsePersona = _personaRepository.Create(persona);

            if (responsePersona.Value)
            {
                alumno.I_PersonaID = int.Parse(responsePersona.CurrentID);

                responseAlumno = _alumnoRepository.Create(alumno);

                return responseAlumno;
            }

            return responsePersona;
        }

        public ResponseData Edit(AlumnoEntity alumnoEntity)
        {
            ResponseData responsePersona;
            ResponseData responseAlumno;

            var persona = Mapper.AlumnoEntityToTC_Persona(alumnoEntity);

            var alumno = Mapper.AlumnoEntityToTC_Alumno(alumnoEntity);

            responsePersona = _personaRepository.Edit(persona);

            if (responsePersona.Value)
            {
                responseAlumno = _alumnoRepository.Edit(alumno);

                return responseAlumno;
            }

            return responsePersona;
        }

        public IEnumerable<AlumnoEntity> GetAll()
        {
            IEnumerable<AlumnoEntity> result;

            var alumnos = _alumnoRepository.GetAll();

            if (alumnos == null)
            {
                result = new List<AlumnoEntity>();
            }
            else
            {
                result = alumnos.Select(a => new AlumnoEntity()
                {

                });
            }

            return result;
        }
    }
}
