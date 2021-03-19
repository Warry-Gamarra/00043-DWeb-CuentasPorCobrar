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
            IEnumerable<SelectViewModel> result;
            
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
                    facultades = programasClient.GetFacultades();

                    result = facultades.Where(f => f.CodFac == "EP").Select(x => new SelectViewModel()
                    {
                        Value = x.CodFac,
                        TextDisplay = x.FacDesc
                    });

                    break;

                default:
                    result = new List<SelectViewModel>();

                    break;
            }

            return result;
        }
    }
}