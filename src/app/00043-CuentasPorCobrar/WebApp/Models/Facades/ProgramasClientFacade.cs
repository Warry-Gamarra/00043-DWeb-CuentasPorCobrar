using Domain.Helpers;
using Domain.UnfvRepositorioClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class ProgramasClientFacade : IProgramasClientFacade
    {
        IProgramasClient programasClient;

        public ProgramasClientFacade()
        {
            programasClient = new ProgramasClient();
        }

        public IEnumerable<SelectViewModel> GetFacultades(TipoEstudio tipoEstudio)
        {
            IEnumerable<FacultadModel> facultades;
            IEnumerable<EscuelaModel> posgrado;
            IEnumerable<SelectViewModel> result;

            try
            {
                switch (tipoEstudio)
                {
                    case TipoEstudio.Pregrado:
                        string[] excluidos = { "CA", "CI", "CP", "CV", "EP", "ET" };

                        facultades = programasClient.GetFacultades();

                        result = facultades.Where(f => !excluidos.Contains(f.CodFac)).Select(x => new SelectViewModel()
                        {
                            Value = x.CodFac,
                            TextDisplay = x.FacDesc
                        }).OrderBy(f => f.TextDisplay);

                        break;

                    case TipoEstudio.Posgrado:
                        posgrado = programasClient.GetEscuelas("EP");

                        result = posgrado.Select(x => new SelectViewModel()
                        {
                            Value = x.CodEsc,
                            TextDisplay = x.EscDesc
                        }).OrderByDescending(f => f.TextDisplay);

                        break;

                    default:
                        result = new List<SelectViewModel>();

                        break;
                }
            }
            catch (Exception)
            {
                result = new List<SelectViewModel>();
            }
            
            return result;
        }
    }
}