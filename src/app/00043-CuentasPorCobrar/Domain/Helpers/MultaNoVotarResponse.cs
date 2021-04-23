using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public class MultaNoVotarResponse
    {
        public MultaNoVotarResponse()
        {
            AlumnoSinVotoRegistrado = new List<AlumnoSinVotoRegistradoEntity>();
        }

        public MultaNoVotarResponse(List<AlumnoSinVotoRegistradoEntity> alumnoSinVotoRegistrado)
        {
            this.AlumnoSinVotoRegistrado = alumnoSinVotoRegistrado;

            Success = true;

            Message = "El registro de los alumnos que no votaron ha finalizado.";

            if (AlumnoSinVotoRegistrado.Count > 0)
                Message = Message + " Se ha encontrado: " + AlumnoSinVotoRegistrado.Count.ToString() +
                    " observacion(es). Haga <a href='/Estudiantes/DescargarMultasSinRegistrar'>click aquí</a> para descargar la lista de observaciones.";
        }

        public bool Success { get; set; }

        public string Message { get; set; }

        public List<AlumnoSinVotoRegistradoEntity> AlumnoSinVotoRegistrado { get; set; }
    }
}
